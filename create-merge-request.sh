#!/bin/bash

# Set the GitLab URL, access token, and project ID
# Set the Gitlab Group if the project is inside one or remove this option from the script
GITLAB_URL="https://gitlab.com"
GROUP=""
ACCESS_TOKEN="$1"
PROJECT_ID="$2"

# Get the source and target branch names from the command line arguments
if [ $# -ne 4 ]; then
  echo "Usage: $0 <access_token> <project_id> <source_branch_name> <target_branch_name>"
  exit 1
fi
SOURCE_BRANCH=$3
TARGET_BRANCH=$4

# Create the merge request title with the branch names substituted in
TITLE="Merge de $SOURCE_BRANCH à $TARGET_BRANCH"

# Get the git project name
GIT_PROJECT=$(git remote -v | awk '{print $2}' | head -1 | sed 's/.*\/\([^ ]*\)\.git/\1/')

# Get the last commit message
LAST_COMMIT_MSG=$(git log --format="%h %s%n%b" -n 1)

# Create a temporary file to store the response
RESPONSE_FILE=$(mktemp)

# Send the request and store the response in the file
curl --silent --location \
  --request POST \
  --header "PRIVATE-TOKEN: $ACCESS_TOKEN" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "source_branch=$SOURCE_BRANCH" \
  --data-urlencode "target_branch=$TARGET_BRANCH" \
  --data-urlencode "title=$TITLE" \
  --data-urlencode "description=$LAST_COMMIT_MSG" \
  "$GITLAB_URL/api/v4/projects/$PROJECT_ID/merge_requests" >"$RESPONSE_FILE" 2>&1

# Read the contents of the file into a variable and delete the file
MERGE_REQUEST=$(cat "$RESPONSE_FILE")
rm "$RESPONSE_FILE"

# Check if the merge request was created successfully
if MERGE_REQUEST_URL=$(echo "$MERGE_REQUEST" | grep -oE '"web_url":"[^"]+"' | cut -d':' -f2- | tr -d '"' | grep -oE 'https://gitlab.com/.*/merge.*'); then
  echo "$TITLE: $MERGE_REQUEST_URL"
  echo ""
else
  # Check if the error message indicates that a merge request already exists
  if echo "$MERGE_REQUEST" | grep -q "Another open merge request already exists"; then
    # Extract the merge request ID from the error message
    MR_ID=$(echo "$MERGE_REQUEST" | grep -oE "\d+")
    # Construct the merge request URL from the ID and print it out
    MR_URL="$GITLAB_URL/$GROUP/$GIT_PROJECT/merge_requests/$MR_ID"
    echo "$TITLE (existant): $MR_URL"
    echo ""
  else
    # Print the error message and exit
    echo "Error: Failed to create merge request"
    echo "$MERGE_REQUEST"
    exit 1
  fi
fi

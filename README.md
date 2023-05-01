# GitLab Merge Request Creation Script

This script is used to create a GitLab merge request from a source branch to a target branch for a given project. The merge request title is automatically generated using the branch names, and the last commit message is used as the description.

## Prerequisites

- Git installed on your machine
- A GitLab account with a personal access token that has the `api` scope
- The project ID for the project you want to create the merge request for

## Usage

1. Clone the repository you want to create the merge request for
2. Move into the repository directory
3. Run the script with the following command:

```
./<path-to-script>/create-merge-request.sh <access_token> <project_id> <source_branch_name> <target_branch_name>
```

- `access_token`: Your GitLab personal access token
- `project_id`: The ID of the project you want to create the merge request for
- `source_branch_name`: The name of the branch you want to merge
- `target_branch_name`: The name of the branch you want to merge into

If the merge request is successfully created, the script will output the merge request title and URL. If a merge request already exists, the script will output the existing merge request title and URL.

## Customization

You can customize the following variables in the script to fit your needs:

- `GITLAB_URL`: The URL of your GitLab instance (defaults to `https://gitlab.com`)
- `GROUP`: The name of the group the project belongs to (optional)

## Notes

- This script requires `curl` to be installed on your machine.
- This script assumes that the remote repository is hosted on GitLab. If you're using a different hosting provider, you may need to modify the `GIT_PROJECT` variable to extract the correct project name.

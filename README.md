# Repository Migration Scripts

This project contains two scripts to aid in migrating repositories in GitLab:

- **migrate_repo.sh**: A Bash script for Linux-based systems
- **migrate_repo.ps1**: A PowerShell script for Windows systems

Both scripts perform the following steps:

1. Creates a "migrations" folder and navigate into it
2. Clones the repository using the `--mirror` flag
3. Navigates into the repository folder
4. Sets the new version control URL for Git
5. Performs `git push`
6. Deletes the repository folder
7. Renames the repository in GitLab using the API

## Prerequisites

The scripts require the following to be installed on your machine:

- Git
- curl
- PowerShell 5.1 or later (for the PowerShell script)

## Usage

### Bash (Linux)

1. Open your terminal
2. Navigate to the directory containing `migrate.sh`
3. Check that the script is executable using the command `ls -l migrate.sh`
    - If the script is not executable, run the command `chmod +x migrate.sh`
4. Run the script using the command `./migrate.sh`
5. Follow the prompts in the terminal to enter the old and new repository URLs

### PowerShell (Windows)

1. Open PowerShell
2. Navigate to the directory containing `migrate.ps1`
3. Run the script using the command `.\migrate.ps1`
4. Follow the prompts in PowerShell to enter the old and new repository URLs

## Note

You will need to insert your GitLab access token in both scripts where indicated by `INSERT_YOUR_ACCESS_TOKEN_HERE`.

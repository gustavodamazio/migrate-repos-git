#!/bin/bash

# Function to retrieve the GitLab project ID based on the repository URL
get_project_id() {
  repo_url=$1
  repo_path=$(basename "$repo_url" .git)
  project_url="https://gitlab.com/api/v4/projects?search=$repo_path"
  access_token=$2
  response=$(curl --silent --header "PRIVATE-TOKEN: $access_token" "$project_url")

  # Check if the response is not empty
  if [ -n "$response" ]; then
    # Extract the project id
    project_id=$(echo "$response" | grep -o '"id":[0-9]*' | cut -d ':' -f 2 | head -1)
  else
    project_id='empty'
  fi

  echo "$project_id"
}


# GitLab URL and Access Token
gitlab_url="https://gitlab.com/api/v4"
access_token="INSERT_YOUR_ACCESS_TOKEN_HERE"  # Replace with your valid access token

# Main function
main() {
  # Step 1 - Create or navigate to the "migrations" folder
  mkdir -p migrations
  cd migrations

  # Step 2 - Clone the repository using the --mirror flag
  echo "Enter the repository URL:"
  read repo_url
  git clone -q --mirror "$repo_url" && echo "Clone successful!" || { echo "Error cloning the repository. Exiting."; exit 1; }

  # Step 3 - Enter the repository folder
  repo_name=$(basename "$repo_url" .git)
  cd "$repo_name.git"

  # Step 4 - Set the new version control URL for Git
  echo "Enter the new repository URL:"
  read new_repo_url
  git remote set-url origin "$new_repo_url" && echo "Repository URL updated successfully!" || { echo "Error updating the repository URL. Exiting."; exit 1; }

  # Step 5 - Perform git push
  git push -q && echo "Push successful!" || { echo "Error performing the push. Exiting."; exit 1; }

  # Step 6 - Delete the repository folder
  cd ../..
  rm -rf migrations

  # Step 7 - Rename the repository in GitLab using the API
  echo "Renaming the repository in GitLab..."
  project_id=$(get_project_id "$repo_url" "$access_token")
  new_repo_name="MIGRATED_$(basename "$repo_url" .git)"
  new_repo_path="MIGRATED_$(basename "$repo_url" .git)"

  curl -s --request PUT --header "PRIVATE-TOKEN: $access_token" \
       "$gitlab_url/projects/$project_id?name=$new_repo_name&path=$new_repo_path" && echo "The repository has been renamed successfully!" || { echo "Error renaming the repository. Exiting."; exit 1; }
}

# Call the main function
main

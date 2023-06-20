# Function to retrieve the GitLab project ID based on the repository URL
function get_project_id {
  param($repo_url, $access_token)
  $repo_path = Split-Path -Path $repo_url -Leaf
  $repo_path = $repo_path.Replace('.git', '')
  $project_url = "https://gitlab.com/api/v4/projects?search=$repo_path"
  $response = Invoke-RestMethod -Uri $project_url -Headers @{"PRIVATE-TOKEN" = "$access_token" }

  # Add this line to print the API response
  Write-Host $response

  $project_id = $response | Select-Object -First 1 -ExpandProperty id
  return $project_id
}

# GitLab URL and Access Token
$gitlab_url = "https://gitlab.com/api/v4"
$access_token = "INSERT_YOUR_ACCESS_TOKEN_HERE"  # Replace with your valid access token

# Main function
function main {
  # Step 1 - Create or navigate to the "migrations" folder
  New-Item -ItemType Directory -Force -Path migrations | Out-Null
  Set-Location -Path migrations

  # Step 2 - Clone the repository using the --mirror flag
  $repo_url = Read-Host -Prompt 'Enter the repository URL'
  git clone -q --mirror "$repo_url"
  if ($LASTEXITCODE -ne 0) { Write-Host "Error cloning the repository. Exiting."; exit 1 }

  # Step 3 - Enter the repository folder
  $repo_name = Split-Path -Path $repo_url -Leaf
  $repo_name = $repo_name.Replace('.git', '')
  Set-Location -Path "$repo_name.git"

  # Step 4 - Set the new version control URL for Git
  $new_repo_url = Read-Host -Prompt 'Enter the new repository URL'
  git remote set-url origin "$new_repo_url"
  if ($LASTEXITCODE -ne 0) { Write-Host "Error updating the repository URL. Exiting."; exit 1 }

  # Step 5 - Perform git push
  git push -q
  if ($LASTEXITCODE -ne 0) { Write-Host "Error performing the push. Exiting."; exit 1 }

  # Step 6 - Delete the repository folder
  Set-Location -Path ../..
  Remove-Item -Recurse -Force migrations

  # Step 7 - Rename the repository in GitLab using the API
  Write-Host "Renaming the repository in GitLab..."
  $project_id = get_project_id $repo_url $access_token
  $repo_name = (Split-Path -Path $repo_url -Leaf).Replace('.git', '')
  $new_repo_name = "MIGRATED_$repo_name"
  $new_repo_path = "MIGRATED_$repo_name"
  $renameProjectBody = @{
    "name" = $new_repo_name
    "path" = $new_repo_path
  } | ConvertTo-Json

  Invoke-RestMethod -Method Put -Uri "$gitlab_url/projects/$project_id" -Headers @{"PRIVATE-TOKEN" = "$access_token" } -Body $renameProjectBody -ContentType "application/json"
  if ($LASTEXITCODE -ne 0) { Write-Host "Error renaming the repository. Exiting."; exit 1 }

  Write-Host "The repository has been renamed successfully!"
}

# Call the main function
main
#requires -Version 3

<#

    Author: Jan De Dobbeleer
    Purpose: Streamline my GitHub Pull Request flow

#>

$global:GitHubPullRequestSettings = New-Object -TypeName PSObject -Property @{
  GitHubApiKey = $null
  BaseBranch = 'master'
}

$settings = $global:GitHubPullRequestSettings

function Get-PullRequests
{
  param(
    $repositoryInfo
  )

  $releaseParams = @{
    Uri         = "https://api.github.com/repos/$($repositoryInfo.User)/$($repositoryInfo.Repository)/pulls"
    Method      = 'GET'
    Headers     = @{
      Authorization = 'Basic ' + [Convert]::ToBase64String(
      [Text.Encoding]::ASCII.GetBytes($settings.GitHubApiKey + ':x-oauth-basic'))
    }
    ContentType = 'application/json'
  }

  $result = Invoke-RestMethod @releaseParams
  return $result
}

function Write-Blank
{
  Write-Host ''
}

function Show-Choices
{
  param(
    [array]
    $pullRequests,
    [string]
    $me
  )
  $i = 1
  Write-Blank
  Write-Host "Hi, $me. Please select a pull request or exit"
  Write-Blank
  foreach($pullRequest in $pullRequests)
  {
    Write-Host "${i}: $($pullRequest.Title)" -NoNewline
    Write-Host " ($($pullRequest.user.login))" -ForegroundColor Yellow
    $i++
  }
  Write-Host "${i}: Exit"
  Write-Blank
  $result = Read-Host 'Selection'
  return $result
}

function Select-Pullrequest
{
  param(
    [array]
    $pullRequests,
    [string]
    $me
  )
  $result = Show-Choices -pullRequests $pullRequests -me $me
  [int]$choice = $null
  while (!([int32]::TryParse($result , [ref]$choice )) -or $choice -lt 1 -or $choice -gt ($pullRequests.length + 1))
  {
    $result = Read-Host 'Please select a correct value'
  }
  if ($choice -gt $result.length)
  {
    Write-Blank
    Write-Host 'Goodbye!'
    return
  }
  return $pullRequests[$choice - 1]
}

function Get-GitRepositoryInfo
{
  $base = git.exe remote get-url origin
  $result = New-Object PSObject -Property @{
    Repository = ($base.Split('/') | Select-Object -Last 1).Replace('.git', '')
    User       = ($base.Split('/') | Select-Object -First 1).Replace('git@github.com:', '')
    Me         = git.exe config user.name
  }
  return $result
}

function Test-NoGitRepository
{
    $status = (Invoke-Expression -Command 'Get-GitStatus')
    return $status -eq $null
}

function Test-PreRequisites
{
    $status = Get-VCSStatus
    if (Test-NoGitRepository) {
      Write-Blank
      Write-Host 'This is not a Git repository'
      Write-Blank
      return $false
    }

    if ($settings.GitHubApiKey -eq $null){
      Write-Blank
      Write-Host 'Please add your GitHub API key to the settings first'
      Write-Blank
      return $false
    }

    return $true
}

function Read-PullRequest
{
  if (!(Test-PreRequisites)) {
    return
  }

  $repositoryInfo = Get-GitRepositoryInfo
  $result = Get-PullRequests -repositoryInfo $repositoryInfo
  if ($result.count -eq 0) {
    Write-Host 'There are no open pull-requests for this repository'
    Write-Blank
    return
  }
  $selectedPullRequest = Select-Pullrequest -pullRequests $result -me $repositoryInfo.Me
  if ($selectedPullRequest -eq $null) {
    Write-Blank
    return
  }
  Write-Blank
  Write-Host 'Fetching origin'
  git.exe fetch origin
  Write-Host 'Creating the diff'
  Write-Blank
  git.exe difftool -d -w $settings.BaseBranch "origin/$($selectedPullRequest.head.ref)"
}

Set-Alias gpr Read-PullRequest -Description "Review a Github pull request"

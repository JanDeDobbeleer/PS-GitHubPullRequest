PS-GitHubPullRequest
====================

A PowerShell tool to interact with the GitHub API and watch/resolve pull requests using your own logic.
More information about why I made this can be found on my [blog](https://herebedragons.io/power_pulling/).

Functionality:
* List the pull request from within a Git repository
* Show the diff displaying the changes
* Resolve the pull request using your own logic
* Create a new pull request for the branch you are currently on

#### Read-PullRequest
<img src="https://herebedragons.io/wp-content/uploads/2016/05/rpr.png">

This will output a list containing the current open pull requests for the current repository if any. When selecting one it will open your difftool showing the changes compared to the base branch.

#### New-PullRequest -title 'Insert your title here'
<img src="https://herebedragons.io/wp-content/uploads/2016/05/npr.png">

Create a new pull request for the branch you are currently on. Requires a title as parameter. If no base branch is given, it will use the one defined in `$GitHubPullRequestSettings.BaseBranch`. You can override the selection of the current branch by providing the `-head` parameter followed by the branch name. Optionally, you can add a body by using `-body 'This is my body'`.

#### Close-PullRequest
<img src="https://herebedragons.io/wp-content/uploads/2016/05/cpr.png">

List the pull request and close it using `git merge <branchname> --ff-only`. If you need a different merge strategy, you can create a new use for the `Invoke-MergeLogic` function in your `Microsoft.PowerShell_profile.ps1` file:

```
function Invoke-MergeLogic
{
  param(
    [Parameter(Mandatory = $true)]
    [object]
    $pullRequest
  )
  Write-Host 'Hello from my settings!'
}
```

The function receives an object called `pullRequest` as parameter. This object is the parsed content of the json reponse received from the GitHub API containing your selected pull request as described in the GitHub [documentation](https://developer.github.com/v3/pulls/#get-a-single-pull-request).

Prerequisites
-------------

Make sure you have Posh-Git installed. I do this using [PsGet](http://psget.net/) :

```
Install-Module posh-git
```

The console experience used in the screenshots is PS-Agnoster, you can find more information [here](https://herebedragons.io/shell-shock/).

Installing
----------

Adjust your `Microsoft.PowerShell_profile.ps1` file to include both Posh-Git and PS-GitHubPullRequest. Make sure the Posh-Git module is sourced before you source PS-GitHubPullRequest.

This example assumes the location of PS-GitHubPullRequest is in the Github folder, adjust to your needs.

```
Import-Module -Name posh-git -ErrorAction SilentlyContinue
. "$env:USERPROFILE\Github\PS-GitHubPullRequest\PS-GitHubPullRequest.ps1"
```

Configuration
-------------

List the current configuration:

````
$GitHubPullRequestSettings
````

<img src="https://herebedragons.io/wp-content/uploads/2016/05/ghprpromptsettings2.png">

You can tweak the settings by manipulating `$GitHubPullRequestSettings`.
This example allows you to tweak the base branch:

````
$GitHubPullRequestSettings.BaseBranch = 'develop'
````

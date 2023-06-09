### PowerShell template profile 
### Version 1.03 - Tim Sneath <tim@sneath.org>
### From https://gist.github.com/timsneath/19867b12eee7fd5af2ba
###
### This file should be stored in $PROFILE.CurrentUserAllHosts
### If $PROFILE.CurrentUserAllHosts doesn't exist, you can make one with the following:
###    PS> New-Item $PROFILE.CurrentUserAllHosts -ItemType File -Force
### This will create the file and the containing subdirectory if it doesn't already 
###
### As a reminder, to enable unsigned script execution of local scripts on client Windows, 
### you need to run this line (or similar) from an elevated PowerShell prompt:
###   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
### This is the default policy on Windows Server 2012 R2 and above for server Windows. For 
### more information about execution policies, run Get-Help about_Execution_Policies.

# Import Terminal Icons
Import-Module -Name Terminal-Icons

# Find out if the current user identity is elevated (has admin rights)
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal $identity
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# If so and the current host is a command line, then change to red color 
# as warning to user that they are operating in an elevated context
# Useful shortcuts for traversing directories
function cd... { Set-Location ..\.. }
function cd.... { Set-Location ..\..\.. }

# Compute file hashes - useful for checking successful downloads 
function md5 { Get-FileHash -Algorithm MD5 $args }
function sha1 { Get-FileHash -Algorithm SHA1 $args }
function sha256 { Get-FileHash -Algorithm SHA256 $args }

# Quick shortcut to start notepad
function n { notepad $args }

# Drive shortcuts
function HKLM: { Set-Location HKLM: }
function HKCU: { Set-Location HKCU: }
function Env: { Set-Location Env: }

# Creates drive shortcut for Work Folders, if current user account is using it
if (Test-Path "$env:USERPROFILE\Work Folders") {
    New-PSDrive -Name Work -PSProvider FileSystem -Root "$env:USERPROFILE\Work Folders" -Description "Work Folders"
    function Work: { Set-Location Work: }
}

# Set up command prompt and window title. Use UNIX-style convention for identifying 
# whether user is elevated (root) or not. Window title shows current version of PowerShell
# and appends [ADMIN] if appropriate for easy taskbar identification
function prompt {
    $currentLocation = Get-Location
    $user = "$env:USERNAME"
    $permission = if ($isAdmin) { "Admin" } else { "Standard" }
    $prompt = ""

    if ($isAdmin) {
        $prompt += "$(Write-Host -NoNewline -ForegroundColor Green $currentLocation)"
        $prompt += "$(Write-Host -NoNewline -ForegroundColor Cyan " $user")"
        $prompt += "$(Write-Host -NoNewline -ForegroundColor Yellow "($permission)")"
        #$prompt += "$(Write-Host -NoNewline -ForegroundColor Red ' #')"
    } else {
        $prompt += "$(Write-Host -NoNewline -ForegroundColor Green $currentLocation)"
        $prompt += "$(Write-Host -NoNewline -ForegroundColor Cyan " $user")"
        $prompt += "$(Write-Host -NoNewline -ForegroundColor Yellow "($permission)")"
        #$prompt += "$(Write-Host -NoNewline -ForegroundColor Red ' $')"
    }

    return $prompt
}

$Host.UI.RawUI.WindowTitle = "PowerShell {0}" -f $PSVersionTable.PSVersion.ToString()
if ($isAdmin) {
    $Host.UI.RawUI.WindowTitle += " [ADMIN]"
}

# Does the rough equivalent of dir /s /b. For example, dirs *.png is dir /s /b *.png
function dirs {
    if ($args.Count -gt 0) {
        Get-ChildItem -Recurse -Include "$args" | Foreach-Object { $_.FullName }
    } else {
        Get-ChildItem -Recurse | Foreach-Object { $_.FullName }
    }
}

# Sets up a "tail" equivalent for PowerShell - continually displays the 
# last 10 lines of a file as they are added
function tail { 
    $file = $args[0]
    $maxLines = $args[1]    
    if (!$maxLines) {
        $maxLines = 10
    }
    while ($true) {
        Get-Content $file -Tail $maxLines
        Start-Sleep -Milliseconds 500
    }
}

# Remove icons (commented out)
# function icon { set-location $args; set-location (Resolve-Path ".") }
# function .. { set-location ..; set-location (Resolve-Path ".") }

# Remove icons (commented out)
# function push-icon { $global:IconStack+=$(get-location); set-location (Resolve-Path ".") }
# function pop-icon { $dest=$global:IconStack[$global:IconStack.length-1]; $global:IconStack=$global:IconStack[0..($global:IconStack.length-2)]; set-location $dest }

# Remove icons (commented out)
# function Icons { 'Desktop', 'Documents', 'Pictures', 'Music', 'Downloads', 'Videos' | % { set-location ("shell:My Computer\{0}" -f $_) } }

# Set default console width
$host.ui.rawui.BufferSize = New-Object System.Management.Automation.Host.Size(120, 3000)

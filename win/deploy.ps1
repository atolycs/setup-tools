# Script version
$script_version = "1.0.0"

function CreateBoxText() {
  [CmdletBinding()]
  Param (
    [Parameter (ValueFromPipeline=$True)][string[]]$input_text,
    [String[]]$Title,
    [String[]]$Ver,
    [String[]]$Url
  )

  Begin {
    $CornerBoxChar = "+"
    $HorizontalBoxChar = "-"
    $VerticalBoxChar = "|"
    $lines = @()


    if ($input_text -eq $null) {
      $input_text = $Title + $Ver + $Url
    }
  }

  Process {
    $maxLength = 0
    $lineCount = 0

    $input_text -split "`r`n" | ForEach-Object {
      $lines += $_
      If ($lines[$lineCount].Length -gt $maxLength) {
        $maxLength = $lines[$lineCount].Length
      }
      $lineCount++
    }
  }

  End {
   $CornerBoxChar + ($HorizontalBoxChar * ($maxLength + 2)) + $CornerBoxChar
   For ($i = 0; $i -lt $lineCount; $i++ ) {
     if ($i -eq 1){
       $VerticalBoxChar + (" " * ($maxLength - $lines[$i].Length - 1)) + $lines[$i] + "   " + $VerticalBoxChar
     } else {
       $VerticalBoxChar + " " + $lines[$i] + (" " * ($maxLength - $lines[$i].Length + 1))  + $VerticalBoxChar
     }
   }
   $CornerBoxChar + ($HorizontalBoxChar * ($maxLength + 2)) + $CornerBoxChar
  }
}

function greeting() {
  CreateBoxText -Title "Atolycs Windows Setup Tools" -Ver "ver: ${script_version}" -Url "https://github.com/atolycs/setup-tools"
}

function info() {
  Param(
   [string[]]$message
  )
  "[ INFO ] " + $message
}

function warn() {
  Param(
   [string[]]$message
  )
  "[ WARN ] " + $message
}

greeting

# ReLaunch Administrator permission
if ( !([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators") ) {
  Start-Process powershell.exe "-ExecutionPolicy Bypass -Command cd $NOW_DIR; $PSCommandPath" -Verb RunAs -Wait
  exit
}


function winget_install() {
  info "Installing winget package..."
  $third_install = @(
    @{Name="7-Zip"; msstore_id="7zip.7zip"};
    @{Name="AWS CLI"; msstore_id="Amazon.AWSCLI"};
    @{Name="Firefox ESR"; msstore_id="Mozilla.Firefox.ESR"};
    @{Name="Google Chrome"; msstore_id="Google.Chrome.EXE"};
    @{Name="Zoom"; msstore_id="Zoom.Zoom.EXE"};
    @{Name="Git for Windows"; msstore_id="Git.Git"};
    @{Name="Notepad++"; msstore_id="Notepad++.Notepad++"};
    @{Name="Tera Term 5"; msstore_id="TeraTermProject.teraterm5"};
    @{Name="Microsoft Visual Studio Code"; msstore_id="Microsoft.VisualStudioCode"};
  )

  $install_list

  ForEach ($str_name in $third_install) {
    $install_list += " " + $str_name.msstore_id
  }

  Write-Host $install_list

  #info ">> Updating Winget source repository..."
  #winget source update

  #info ">> Installing Packages..."
  #winget install $install_list --source winget

}


function main() {
  winget_install
  
}

main

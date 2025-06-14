# Script version
$script_version = "1.0.0"
$script_url = "https://raw.githubusercontent.com/atolycs/setup-tools/refs/heads/main/win/winget_update.ps1"

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
  Write-Host "[ INFO ] $message"
}

function warn() {
  Param(
   [string[]]$message
  )
  Write-Host "[ WARN ] $message"
}

greeting

# ReLaunch Administrator permission
function ReLaunchAdmin() {
  $currentProcess = Get-CurrentProcess
  Write-Host $currentProcess
  if ($currentProcess.Name -eq "WindowsTerminal") {
	  Write-Host "Calling $($MyInvocation.MyCommand)"
	  info "Windows Terminal Killing..."
	  #$command = "cd '$pwd'; $($MyInvocation.ScriptName)"
	  $command = "iwr $script_url | iex" 

	  Start-Process -FilePath "conhost.exe" -ArgumentList "powershell -WindowStyle Normal -ExecutionPolicy Bypass -Command &{$command}" -Verb RunAs 

	  Stop-Process -id $currentProcess.Id
  }
  warn "ReLaunching Admin Rights..."
  if ( !([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole("Administrators") ) {
    Start-Process powershell.exe "-ExecutionPolicy Bypass -Command `"iwr $script_url | iex`"" -Verb RunAs -Wait
    exit
  }
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
  
  info ">> Updating Winget source repository..."
  winget source update

  $install_list = ""

  ForEach ($str_name in $third_install) {
    info ">> Installing $($str_name.Name) Packages..."
    winget install $str_name.msstore_id --source winget
  }



}

function sudo_enabler() {
  info ">> Enabling sudo for Windows..."
  sudo config --enable forceNewWindow
}

function reg_add() {
  info ">> Adding Registry..."
      $set_key = @(
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarDa"; PropertyType="DWord"; Value="0";};
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="TaskbarMn"; PropertyType="DWord"; Value="0";};
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"; Name="Hidden"; PropertyType="DWord"; Value="1";};
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"; Name="AllItemsIconView"; PropertyType="DWord"; Value="0";};
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"; Name="StartupPage"; PropertyType="DWord"; Value="1";};

      # Personal Desktop Icon
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"; Name="{59031a47-3f72-44a7-89c5-5595fe6b30ee}"; PropertyType="DWord"; Value="0";};

      # This PC 
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"; Name="{20D04FE0-3AEA-1069-A2D8-08002B30309D}"; PropertyType="DWord"; Value="0";};

      # Network
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"; Name="{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"; PropertyType="DWord"; Value="0";};

      # Control Panel
      @{Key="HKCU:Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"; Name="{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"; PropertyType="DWord"; Value="0";};

      @{Key="HKCU:Control Panel\Desktop"; Name="PaintDesktopVersion"; PropertyType="DWord"; Value="1";};
      @{Key="HKLM:SYSTEM\CurrentControlSet\Control\Session Manager\Power"; Name="HiberbootEnabled"; PropertyType="DWord"; Value="0";};
    )

    ForEach ($str_key in $set_key) {
      info("Setting Registry Key: " + $str_key.Key + "\" + $str_key.Name + " " + " Value: " + $str_key.Value)
      New-Item $str_key.Key -ErrorAction SilentlyContinue
      New-ItemProperty -LiteralPath $str_key.Key -Name $str_key.Name -PropertyType $str_key.PropertyType -Value $str_key.Value -Force 
    }
}

function end_message() {
  info "Setup complited"
  info "Please Restart Computer"
  pause
  Restart-Computer
}

#function update_winget() {
#  $command = "cd '$pwd'; $($MyInvocation.Line)"
#  info ">> Updating winget..."
#  Install-Module -Name Microsoft.Winget.Client -Force -AllowClobber -Repository PSGallery
#  info ">> Installing winget..."
#  Repair-WingetPackageManager -AllUsers
#
#  info ">> Fixing Winget path..."
#  $WinGetFolderPath = (Get-ChildItem -Path ([System.IO.Path]::Combine($env:ProgramFiles, 'WindowsApps')) -Filter "Microsoft.DesktopAppInstaller_*_${arch}__8wekyb3d8bbwe" | Sort-Object Name | Select-Object -Last 1).FullName
#
#  if ($null -ne $WinGetFolderPath) {
#    $systemEnvPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine)
#    $systemEnvPath += ";$WinGetFolderPath"
#    [System.Environment]::SetEnvironmentVariable('PATH', $systemEnvPath, [System.EnvironmentVariableTarget]::Machine)
#  }
#}

function Get-CurrentProcess {

    $oldTitle = $host.ui.RawUI.WindowTitle
    $tempTitle = ([Guid]::NewGuid())
    $host.ui.RawUI.WindowTitle = $tempTitle
    Start-Sleep 1
    $currentProcess = Get-Process | Where-Object { $_.MainWindowTitle -eq $tempTitle }
    $currentProcess = [PSCustomObject]@{
        Name = $currentProcess.Name
        Id   = $currentProcess.Id
    }
    $host.ui.RawUI.WindowTitle = $oldTitle
    return $currentProcess
}

function update_winget() {

  $download_tmp = New-TempDirectory

  Write-Host $download_tmp
  cd $download_tmp

  $winget_API = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
  $winget_DL = $(Invoke-RestMethod $winget_API).assets.browser_download_url | Where-Object {$_.EndsWith(".msixbundle")}
  $winget_Dependicies_DL = $(Invoke-RestMethod $winget_API).assets.browser_download_url | Where-Object {$_.EndsWith("_Dependencies.zip")}
  
  info ">> Downloading Packages..."
  iwr -Uri $winget_DL -OutFile "winget.msixbundle" -UseBasicParsing
  iwr -Uri $winget_Dependicies_DL -OutFile "deps.zip" -UseBasicParsing


  info ">> Expanding and Installing Winget Dependencies..."
  New-Item -ItemType "Directory" -Path deps
  Expand-Archive -Path "deps.zip" -DestinationPath .\deps
  Add-AppxPackage -Path .\deps\x64\*.appx

  info ">> Installing winget package..."
  Add-AppxPackage -Path "winget.msixbundle"

  info ">> Removing tmp folders..."
  cd $env:USERPROFILE
  Remove-Item -Recurse $download_tmp

}

function New-TempDirectory {
    $path = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    #if/while path already exists, generate a new path
    while(Test-Path $path) {
        $path = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
    }

    #create directory with generated path
    New-Item -ItemType Directory -Path $path
}

function main() {
  reg_add
  ReLaunchAdmin 
  sudo_enabler
  update_winget
  #  winget_install 
  end_message
}

main

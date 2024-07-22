# Windows setup tools

$script_version = "1.0.0"

function greeting() {
    Write-Host "+-----------------------------------------+"
    Write-Host "|  Atolycs Windows Setup Tools            |"
    Write-Host "|                              ver ${script_version}  |"
    Write-Host "|                              Atolycs    |"
    Write-Host "+-----------------------------------------+"
}

function info() {
    Param($str)
    Write-Host -NoNewline "[ "
    Write-Host -NoNewline "INFO" -ForegroundColor Green
    Write-Host -NoNewline " ] "
    Write-Host $str
}

function warn() {
    Param($str)
    Write-Host -NoNewline "[ "
    Write-Host -NoNewline "WARN" -ForegroundColor Yellow
    Write-Host -NoNewline " ] "
    Write-Host $str
}

function winget_install() {
  #ref: https://learn.microsoft.com/en-us/windows/package-manager/winget/
    $latest_winget = "https://aka.ms/getwinget"
    $latest_vclib = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $latest_xaml = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"

    info("Installing winget and dependencies...")
    info(">> Downloading VCLibs...")
    Invoke-WebRequest -Uri $latest_vclib -OutFile VCLibs.appx
    info(">> Downloading Microsoft Xaml...")
    Invoke-WebRequest -Uri $latest_xaml -OutFile Xaml.appx
    info(">> Downloading Winget...")
    Invoke-WebRequest -Uri $latest_winget -OutFile winget.appx

    info(">> Installing winget...")
    Add-AppxPackage -Path VCLibs.appx
    Add-AppxPackage -Path Xaml.appx
    Add-AppxPackage -Path winget.appx 

    info(">> Remove Install package")

    Remove-Item -Path VCLibs.appx
    Remove-Item -Path Xaml.appx
    Remove-Item -Path winget.appx
}

function install_package() {

    $third_install = @(
        @{Name="GitHub CLI"; msstore_id="GitHub.cli"};
        @{Name="Git for Windows"; msstore_id="Git.Git"};
        @{Name="7-Zip"; msstore_id="7zip.7zip"};
        @{Name="Visual Studio Code"; msstore_id="Microsoft.VisualStudioCode"};
        @{Name="Notepad++"; msstore_id="Notepad++.Notepad++"};
        @{Name="Oh-My-Posh"; msstore_id="JanDeDobbeleer.OhMyPosh"};
        @{Name="Powershell 7"; msstore_id="Microsoft.Powershell"};
        @{Name="Zig Compiler"; msstore_id="zig.zig"};
    )

    info("Updating winget source ...")

    winget source update --disable-interactivity

    ForEach($str_name in $third_install) {
        info(">> Installing " + $str_name.Name + "...")
        winget install $str_name.msstore_id --source winget
    }
}

function deploy_dotfiles() {
    info("Downloading Atolycs dotfiles...")

    if (-Not (Get-Command git)) {
        warn("Not Found. Downloading git...")
        warn("Running Command: winget install git.git")
        winget install git.git
    }

    git clone https://github.com/atolycs/dotfiles -b dev
}

function uninstall_preinstalled() {
    info("Removing Preinstalled software...")

    $uninstall_list = @(
        @{Name=""; msstore_id="";};
    )

    ForEach ($str_name in $uninstall_list) {
        info("Uninstalling " + $str_name.Name + " ...")
        Uninstall-Package($str_name.msstore_id) 
    }
}

function add_gitconfig() {
  info("Setting up git configuration...")
  New-Item -ItemType File -Path "$env:USERPROFILE\.gitconfig" 

  $git_path = "C:\Program Files"
  Start-Process -Wait powershell -ArgumentList "-Command git config --global http.sslbackend schannel"
}

function farewall_greeting() {
    info("Deploy complited")
    info("Please Restart Machine.")
    info("Thank you use this script.")
}

function add_known_hosts() {
    if (-Not (Get-Command ssh-keyscan)) {
        warn("ssh-keyscan.exe not found")
    }

    if (-Not (Test-Path ~/.ssh)) {
        mkdir ~/.ssh
    }

    $add_host_keys = @(
        @{Name="ssh.github.com"};
        @{Name="github.com"};
    )
    ForEach ($str_name in $add_host_keys) {
        info("Adding host key: " + $str_name.Name + " ...")
        ssh-keyscan -H -t ed25519 $str_name | Tee-Object -Filepath ~/.ssh/known_hosts
    }
}

function Uninstall-Package() {
    Param(
        $App_id
    )
    Get-AppxPackage $App_id | Remove-AppxPackage
}

greeting

# Winget install
winget_install

# Install from winget
install_package

# deploy dotfiles
#deploy_dotfiles

# ssh known_hosts
add_known_hosts

#add_gitconfig

farewall_greeting

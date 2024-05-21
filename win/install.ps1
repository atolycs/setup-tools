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
    $latest_winget = "https://aka.ms/getwinget"
    $latest_vclib = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
    $latest_xaml = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"

    info("Installing winget and dependencies...")
    Invoke-WebRequest -Uri $latest_vclib -OutFile VCLibs.appx
    Invoke-WebRequest -Uri $latest_xaml -OutFile Xaml.appx
    Invoke-WebRequest -Uri $latest_winget -OutFile winget.appx

    Add-AppxPackage -Path VCLibs.appx
    Add-AppxPackage -Path Xaml.appx
    Add-AppxPackage -Path winget.appx 

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
        @{Name=""; msstore_id=""};
    )

    info("Updating winget source ...")

    winget source update --disable-interactivity

    ForEach($str_name in $third_install) {
        if ($str_name.Name -eq "" -and $str_name.msstore_id -eq "") {
            info("End Of Array")
            break;
        }

        info("Installing ${str_name.Name} ...")
        winget insteall $str_name.msstore_id --source winget
    }
}


greeting

# Winget install
winget_install

# Install from winget
install_package
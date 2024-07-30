# Windows setup tools

$script_version = "1.0.0"

function greeting() {
    Write-Host "+-----------------------------------------+"
    Write-Host "|  Atolycs Windows Setup Tools            |"
    Write-Host "|                              ver ${script_version}  |"
    Write-Host "|                              Atolycs    |"
    Write-Host "+-----------------------------------------+"
    info("This script will install additional packages.")
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

function install_package() {

    $third_install = @(
        @{Name="GitHub CLI"; msstore_id="GitHub.cli"};
        @{Name="Git for Windows"; msstore_id="Git.Git"};
        @{Name="Zig Compiler"; msstore_id="zig.zig"};
        @{Name="NeoVim"; msstore_id="NeoVim.NeoVim"};
        @{Name="KeePassXC"; msstore_id="KeePassXCTeam.KeePassXC"};
    )

    info("Updating winget source ...")

    winget source update --disable-interactivity

    ForEach($str_name in $third_install) {
        info(">> Installing " + $str_name.Name + "...")
        winget install $str_name.msstore_id --source winget
    }
}

function farewall_greeting() {
    info("Deploy complited")
    info("Please Restart Machine.")
    info("Thank you use this script.")
}

function Uninstall-Package() {
    Param(
        $App_id
    )
    Get-AppxPackage $App_id | Remove-AppxPackage
}

greeting

# Install from winget
install_package

farewall_greeting

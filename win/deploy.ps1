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


info "INFO TEST"
warn "WARN TEST"



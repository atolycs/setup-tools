function reg_add {
    [CmdletBinding()]
    param()

    Write-Host ">> Adding Registry using ..."

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

    function Resolve-Hive {
        param([string]$hiveToken)

        switch ($hiveToken.ToUpper()) {
            'HKCU' {'CurrentUser'}
            'HKEY_CURRENT_USER' {'CurrentUser'}
            'HKLM' {'LocalMachine'}
            'HKEY_LOCAL_MACHINE' {'LocalMachine'}
            'HKCR' {'ClassesRoot'}
            'HKEY_CLASSES_ROOT' {'ClassesRoot'}
            'HKU' {'Users'}
            'HKEY_USERS' {'Users'}
            'HKCC' {'CurrentConfig'}
            'HKEY_CURRENT_CONFIG' {'CurrentConfig'}
            default { throw "Unknown hive token: $hiveToken" }
        }
    }

    foreach ($entry in $set_key) {
        try {
            if ($entry.Key -notmatch '^([^:]+):\\?(.*)$') {
                Write-Warning "Invalid key format: $($entry.Key)"
                continue
            }
            $hiveToken = $matches[1]
            $subPath = $matches[2]

            $hiveName = Resolve-Hive -hiveToken $hiveToken
            $root = [Microsoft.Win32.Registry]::$hiveName

            if ([string]::IsNullOrEmpty($subPath)) {
                # 値をルートに書く場合
                $targetKey = $root
            } else {
                # CreateSubKey は親キーが無ければ再帰的に作成する（ここが重要）
                $targetKey = $root.CreateSubKey($subPath)
            }

            if (-not $targetKey) {
                Write-Warning "Failed to open/create key: $($entry.Key)"
                continue
            }

            # PropertyType -> RegistryValueKind へのマッピング
            switch ($entry.PropertyType.ToString().ToLower()) {
                'dword' { $kind = [Microsoft.Win32.RegistryValueKind]::DWord; $val = [int]$entry.Value }
                'qword' { $kind = [Microsoft.Win32.RegistryValueKind]::QWord; $val = [long]$entry.Value }
                'string' { $kind = [Microsoft.Win32.RegistryValueKind]::String; $val = [string]$entry.Value }
                'expandstring' { $kind = [Microsoft.Win32.RegistryValueKind]::ExpandString; $val = [string]$entry.Value }
                'multistring' { $kind = [Microsoft.Win32.RegistryValueKind]::MultiString; 
                                if ($entry.Value -is [array]) { $val = $entry.Value } else { $val = @([string]$entry.Value) } }
                default { $kind = [Microsoft.Win32.RegistryValueKind]::String; $val = [string]$entry.Value }
            }

            # 値を設定（既存があれば上書きされます）
            $targetKey.SetValue($entry.Name, $val, $kind)
            $targetKey.Close()

            Write-Host "Set: $($entry.Key)\$($entry.Name) = $val ($kind)"
        } catch {
            Write-Warning "Failed to set $($entry.Key)\$($entry.Name): $($_.Exception.Message)"
        }
    }

    Write-Host ">> Registry updates finished."
}

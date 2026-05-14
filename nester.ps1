param(
    [switch]$ElevatedMenu
)

function Show-SimpleSelectorMenu {
    param (
        [string[]]$Options,
        [string]$Title = "Use Up/Down to move, Space to select, Enter to continue",
        [switch]$MultiSelect
    )

    $cursorIndex = 0
    $selectedIndexes = New-Object System.Collections.Generic.HashSet[int]

    while ($true) {
        Clear-Host
        Write-Host $Title -ForegroundColor Yellow
        Write-Host ""

        for ($i = 0; $i -lt $Options.Count; $i++) {
            $cursor = if ($i -eq $cursorIndex) { ">" } else { " " }
            $selected = if ($selectedIndexes.Contains($i)) { "[x]" } else { "[ ]" }
            Write-Host "$cursor $selected $($Options[$i])"
        }

        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

        switch ($key.VirtualKeyCode) {
            38 { # Up Arrow
                if ($cursorIndex -gt 0) {
                    $cursorIndex--
                } else {
                    $cursorIndex = $Options.Count - 1
                }
            }
            40 { # Down Arrow
                if ($cursorIndex -lt ($Options.Count - 1)) {
                    $cursorIndex++
                } else {
                    $cursorIndex = 0
                }
            }
            32 { # Space
                if ($selectedIndexes.Contains($cursorIndex)) {
                    [void]$selectedIndexes.Remove($cursorIndex)
                } elseif ($MultiSelect) {
                    [void]$selectedIndexes.Add($cursorIndex)
                } else {
                    $selectedIndexes.Clear()
                    [void]$selectedIndexes.Add($cursorIndex)
                }
            }
            13 { # Enter
                if ($selectedIndexes.Count -gt 0) {
                    $orderedSelections = $selectedIndexes | Sort-Object
                    $selectedOptions = foreach ($idx in $orderedSelections) { $Options[$idx] }

                    if ($MultiSelect) {
                        return ,$selectedOptions
                    }

                    return $selectedOptions[0]
                }
            }
        }
    }
}

if (-not $ElevatedMenu) {
    $menuOptions = @(
        "Run script (Admin flow)",
        "Exit"
    )

    $choice = Show-SimpleSelectorMenu -Options $menuOptions

    if ($choice -eq "Exit") {
        Write-Host "Exiting..."
        exit
    }
}

# Check for Admin privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Relaunch this script as admin and enter elevated menu mode.
    Start-Process powershell.exe -Verb RunAs -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", $PSCommandPath,
        "-ElevatedMenu"
    )
} else {
    $birdOptions = @(
        "Sparrow",
        "Falcon",
        "Raven",
        "Owl",
        "Heron"
    )

    $selectedBirds = Show-SimpleSelectorMenu -Options $birdOptions -Title "Elevated menu: Use Up/Down, Space to toggle, Enter to continue" -MultiSelect

    Write-Host "You selected: $($selectedBirds -join ', ')" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit
}
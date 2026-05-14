# 1. Check for Admin privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # 2. Launch new elevated window and pass the command to Caw and then wait
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-Command", "Write-Host 'Caw' -ForegroundColor Cyan; Read-Host 'Press Enter to exit'"
} else {
    # 3. If already admin, just Caw and wait
    Write-Host "Caw" -ForegroundColor Cyan
    Read-Host "Press Enter to exit"
    exit
}
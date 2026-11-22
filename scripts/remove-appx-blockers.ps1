# Removes bloat and Store apps known to make Sysprep fail.
# Run in Audit Mode, as Administrator, with Wi-Fi OFF:
#   powershell -ExecutionPolicy Bypass -File .\remove-appx-blockers.ps1

$patterns = @(
    '*aimgr*',
    '*PhotoshopExpress*',
    '*Xbox*',
    '*BingNews*',
    '*BingWeather*',
    '*BingSearch*',
    '*MicrosoftSolitaireCollection*',
    '*Clipchamp*',
    '*McAfee*'
)

foreach ($p in $patterns) {
    Get-AppxPackage -AllUsers -Name $p -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "Removing package $($_.PackageFullName)"
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $p | ForEach-Object {
        Write-Host "Removing provisioned $($_.DisplayName)"
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
    }
}

Write-Host "`nDone. If Sysprep still fails, check C:\Windows\System32\Sysprep\Panther\setupact.log for the blocking package name."

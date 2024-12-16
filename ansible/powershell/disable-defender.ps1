# Check for existence of Windows Defender service
Write-Output "[ ] Checking if Windows Defender is running"
Get-Service -Name WinDefend -ErrorVariable err -ErrorAction SilentlyContinue
if (!$err)
{
    # Uninstall Windows Defender service
    Write-Output "[*] Windows Defender found"
    Write-Output "[ ] Attempting to uninstall Windows Defender"
    Uninstall-WindowsFeature -Name Windows-Defender -ErrorAction stop
    Write-Output "[*] Successfully ran uninstall command"
    Write-Output "[ ] Rebooting and then checking if uninstall was successful"
    exit 0
}

# Check for expected error
if ($err[0].FullyQualifiedErrorId -eq "NoServiceFoundForGivenName,Microsoft.PowerShell.Commands.GetServiceCommand")
{
    Write-Output "[ ] Windows Defender not found, skipping removal"
    exit 0
}
else {
    # Print output of unexpected error
    Write-Output "[ ] An unexpected error occurred"
    Write-Output $err[0]
    exit 1
}

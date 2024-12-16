# Ensure that Windows Defender has been uninstalled
Write-Output "[ ] Checking if Windows Defender is running"
Get-Service -Name WinDefend -ErrorVariable err -ErrorAction SilentlyContinue

if (!$err) {
    Write-Error "[X] Failed to uninstall Windows Defender" -ErrorAction Stop
    exit 1
}

# Check for expected error
if ($err[0].FullyQualifiedErrorId -eq "NoServiceFoundForGivenName,Microsoft.PowerShell.Commands.GetServiceCommand")
{
    Write-Output "[*] Windows Defender successfully uninstalled"
    exit 0
}
else
{
    # Print output of unexpected error
    Write-Output "[ ] An unexpected error occurred"
    Write-Output $err[0]
    exit 1
}

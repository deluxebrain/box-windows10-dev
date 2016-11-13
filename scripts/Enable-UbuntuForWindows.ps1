$Logfile = "C:\Windows\Temp\provisioning.log"

function Write-Log
{
    Param ([string]$message)
    $now = Get-Date -format s
    Add-Content $Logfile -value "$now $message"
    Write-Host $message
}

function Check-WindowsVersion
{
    # Validate Windows 10 version 1607 build
    if ([int](Get-WmiObject -Class Win32_OperatingSystem).BuildNumber -lt 14393)
    {
        Write-Log "Unsupported build of Windows 10 detected, exiting" ; exit 1
    }
}

function Enable-DeveloperMode
{
    # Create AppModelUnlock if it doesn't exist, required for enabling Developer Mode
    $RegistryKeyPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    if (-not(Test-Path -Path $RegistryKeyPath)) {
        Write-Log "Creating HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock registry key"
        New-Item -Path $RegistryKeyPath -ItemType Directory -Force
    }

    # Add registry value to enable Developer Mode
    Write-Log "Adding HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock\AllowDevelopmentWithoutDevLicense value as DWORD with data 1"
    New-ItemProperty -Path $RegistryKeyPath -Name AllowDevelopmentWithoutDevLicense -PropertyType DWORD -Value 1
}

function Enable-LinuxSubsystem
{
    # Enable required Windows Features for Linux Subsystem
    try
    {
        Enable-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online -All -LimitAccess -NoRestart -ErrorAction Stop
        Write-Log "Successfully enabled Microsoft-Windows-Subsystem-Linux feature" -Severity 1
    }
    catch [System.Exception]
    {
        Write-Log "An error occured when enabling Microsoft-Windows-Subsystem-Linux feature"
    }
}

Check-WindowsVersion
Enable-DeveloperMode
Enable-LinuxSubsystem


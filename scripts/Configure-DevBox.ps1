Update-ExecutionPolicy -Policy Unrestricted

# Boxstarter options
$Boxstarter.RebootOk = $true

# Windows options
Set-WindowsExplorerOptions -EnableShowHiddenFilesFoldersDrives -EnableShowProtectedOSFiles -EnableShowFileExtensions

# Windows updates
Install-WindowsUpdate -AcceptEula
if (Test-PendingReboot){ Invoke-Reboot }

# Windows features
choco install IIS-WebServerRole -source windowsfeatures

# .Net and Visual Studio
choco install dotnet4.5 -y --ignore-checksums
choco install dotnet4.6 -y --ignore-checksums
choco install dotnet4.6.1 -y --ignore-checksums
choco install visualstudio2015professional -y --ignore-checksums
choco install dotnet4.6-targetpack -y --ignore-checksums
choco install resharper -y --ignore-checksums
choco install visualstudiocode -y --ignore-checksums
choco install webpicmd -y --ignore-checksums

# Node
choco install nodejs.install -y --ignore-checksums

# Ruby
choco install ruby -y --ignore-checksums
choco install ruby.devkit -y --ignore-checksums

# Go
choco install golang -y --ignore-checksums

# Python
choco install python -y --ignore-checksums
choco install pip -y --ignore-checksums
choco install easy.install -y --ignorechecksums

# DevOps
choco install awscli -y --ignore-checksums
choco install awstools.powershell -y --ignore-checksums

# Development tooling
#choco install sublimetext3 -y --ignore-checksums
#choco install NugetPackageExplorer -y --ignore-checksums
#choco install git.intall -y --ignore-checksums
#choco install git-credential-manager-for-windows -y --ignore-checksums
#choco install poshgit -y --ignore-checksums
#choco install fiddler -y --ignore-checksums
#choco install phantomjs -y --ignore-checksums

# Browsers
#choco install GoogleChrome -y --ignore-checksums
#choco install Firefox -y --ignore-checksums
#choco install Opera -y --ignore-checksums

# Powertools
#choco install pandoc -y --ignore-checksums
#choco install winrar -y --ignore-checksums
#choco install postman -y --ignore-checksums
#choco install vlc -y --ignore-checksums
#choco install 7zip.install -y --ignore-checksums

# MySQL
#choco install mysql.workbench -y --ignore-checksums
#choco install mysql -y --ignore-checksums

# Comms
#choco install slack -y --ignore-checksums


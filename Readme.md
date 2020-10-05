# Choco School

My scripts to use [Chocolatey](http://chocolatey.org/) in a school.

### Local repository
Your public IP will get banned if 100s of computers are downloading nupkg files from chocolatey.org, so we'll need a local repo. Easiest thing is just a shared drive.

0. Get the install script from https://chocolatey.org/docs/installation#completely-offline-install
It starts with ```# Download and install Chocolatey nupkg from an OData (HTTP/HTTPS) url such as Artifactory, Nexus, ProGet (all of these are recommended for organizational use), or Chocolatey.Server (great for smaller organizations and POCs)``` and save it as ChocolateyLocalInstall.ps1

1. Create a read only share, with 3 folders, files, config, packages. Optionally set up a log share.

2. Download packages from https://chocolatey.org and put them in packages folder
Create xml files (some examples provided) to config which computers get which packages

3. Put the ps1 and bat files in files folder

4. Make the computers install install.bat on startup

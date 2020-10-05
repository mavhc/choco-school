# compare packages in local repo to community repo, download new versions
# needs Chocolatey installed

# Thanks to bog for this function
function Get-NUPKG-Version {
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $fullpath
  )
  
  Add-Type -assembly "system.io.compression.filesystem"
  $zip = [io.compression.zipfile]::OpenRead($fullpath)
  $file = $zip.Entries | where-object { $_.Name -Like "*.nuspec"}
  $stream = $file.Open()

  $reader = New-Object IO.StreamReader($stream)
  $text = $reader.ReadToEnd()

  $reader.Close()
  $stream.Close()
  $zip.Dispose()

  $xml = [xml]$text
  $version = $xml.package.metadata.version
  return $version
}
function Get-NUPKG-Name {
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    [string] $fullpath
  )
  Add-Type -assembly "system.io.compression.filesystem"
  $zip = [io.compression.zipfile]::OpenRead($fullpath)
  $file = $zip.Entries | where-object { $_.Name -Like "*.nuspec"}
  $stream = $file.Open()

  $reader = New-Object IO.StreamReader($stream)
  $text = $reader.ReadToEnd()

  $reader.Close()
  $stream.Close()
  $zip.Dispose()

  $xml = [xml]$text
  $packageName = $xml.package.metadata.id
  return $packageName
}

# Use system proxy, user creds
$Wcl = new-object System.Net.WebClient
$Wcl.Headers.Add("user-agent", "PowerShell Script")
$Wcl.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

Write-output "Getting list of packages"
$outputUnsorted = Get-ChildItem -path \\server\share$\choco\packages -Recurse -Attributes !Directory -Filter *.nupkg

# sort by package name, then package version, using dotnet's [version] data type
$output = ($outputUnsorted | Sort-Object -property @{ Expression = { (Get-NUPKG-Name($_.FullName)) } }, @{ Expression = { [version] (Get-NUPKG-Version($_.FullName)) } } )

# checks package with next package on list, if different then latest version in local repo, compare to community repo, download new versions
for ($i=0; $i -lt $output.length; $i++) {
    $package = $output[$i]
    Write-Output "Checking $package"
    
    $packageName = Get-NUPKG-Name($package.Fullname)
    
    if ($i -lt $output.Length-1) {
        $nextPackageName = Get-NUPKG-Name($output[$i+1].FullName)
        if ($nextPackageName -ne $packageName ) {
            Write-Output "latest local version $package"
            
            $latestPackage = choco info $packageName --limit-output
            Write-Output "Comparing $packageName : new version $latestPackage to old version $package"
            
            $a = $latestPackage.split("|")
            $newFileName = $latestPackage.Replace("|",".") + ".nupkg"
            
            if ($newFilename -ne $package) {
                $b = "https://chocolatey.org/api/v2/package/$packageName/$($a[1])"
                Write-Output "Downloading $b"
                Invoke-WebRequest -uri $b -OutFile "$($a[0]).$($a[1]).nupkg"
            }
        }
    }
}
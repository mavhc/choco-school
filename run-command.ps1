# get computer name, if it contains -s then split on those dashes and try to find
# school.config, school-it.config, and school-it-01.config
# if no - then do the same, but per character

# install packages from all those xml files, then upgrade all
# run the choco-cleaner scheduled task soon
# log any outdated packages to server
# uninstall unwanted packages
$name = $env:computername
#example: $name = "school-it-01"
$nameparts = $name.split("-")
$currentprefix = ""
if ($nameparts.length -eq 1) {
    #no dashes in name, so iterate per character
    $name = $name.toCharArray()
    write-output "no -"
    ForEach ($char in $name) {
        $currentprefix += $char
        write-output $currentprefix
        $path = "\\school.local\share$\choco\config\" + $currentprefix + ".config"
        choco install $path
    }
} else {
    ForEach ($part in $nameparts) {
        if ($currentprefix.Length -gt 0)
           { $currentprefix += "-" + $part }
        else
           { $currentprefix = $part }
        write-output $part, $currentprefix
        $path = "\\school.local\share$\choco\config\" + $currentprefix + ".config"
        choco install $path
    }
}

# Default xml list of packages
$path = "\\school.local\share$\SoftwareInstall\choco\config\school.config"
choco install $path

choco upgrade all

# Don't forget to install the choco-cleaner package
$a = New-ScheduledTaskSettingsSet -StartWhenAvailable
Set-ScheduledTask "choco-cleaner" -Settings $a

# Store list of outdated packages on server
$pathname =  "\\school.local\share$\logs\choco\"+$name+".txt"
choco outdated > $pathname

# list of things to uninstall, can't use xml yet
choco uninstall aegisub
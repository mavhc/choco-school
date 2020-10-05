Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('\\school.local\share$\choco\files\ChocolateyLocalInstall.ps1'))
choco source remove --name="'chocolatey'"
choco source add --name="'internal_server'" --source="\\school.local\share$\choco\packages" --priority="'1'"
choco feature enable -n allowGlobalConfirmation
choco feature enable -n useRememberedArgumentsForUpgrades


$GotTask         = (&schtasks /query /tn choco-installer) 2> $null

if ($GotTask -eq $null)
{

# SchTasks /Create /SC WEEKLY /D SUN /RU SYSTEM /RL HIGHEST /TN "choco-cleaner" /TR "cmd /c powershell -NoProfile -ExecutionPolicy Bypass -Command choco update" /ST 23:00 /F

$oneday = New-TimeSpan -Hours 24
$fourhours = New-TimeSpan -Hours 4
$oneweek = New-TimeSpan -Days 7

$A = New-ScheduledTaskAction -Execute "\\school.local\share$\choco\files\run-command.ps1"
$T = New-ScheduledTaskTrigger -daily  -daysinterval 1 -at 3am -RandomDelay $fourhours
$P = New-ScheduledTaskPrincipal -UserID "NT AUTHORITY\SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$S = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable -DisallowHardTerminate -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -MaintenanceDeadline $oneweek -MaintenancePeriod $oneday
$D = New-ScheduledTask -Action $A -Principal $P -Trigger $T -Settings $S -Description "Run choco upgrade all" #-AsJob
Register-ScheduledTask -TaskName "choco-installer" -InputObject $D

}

\\school.local\share$\choco\files\run-command.ps1
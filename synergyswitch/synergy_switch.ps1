#control monitor has get-value but it does not work with my setup, so I keep a variable around to understand what is my last state of input. Here the ps script is running from server
Remove-Variable * -ErrorAction SilentlyContinue
$host.PrivateData.ConsolePaneBackgroundColor = "Black"
$host.PrivateData.ConsolePaneTextBackgroundColor = "Black"
cls
write-host -ForegroundColor Red "Synergy Switch PS - Authored by: Young Chang (tomchang3@gmail.com)"
write-host ""

$scriptdir = Split-Path $PSCommandPath -Parent
try {$t_scriptdir = Test-Path $scriptdir} catch {$scriptdir = $false}
while (!$t_scriptdir) {
    write-host -ForegroundColor Darkred "script path: "
    #$scriptpath = Read-Host "enter the correct script path" 
    try {$scriptdir = Test-Path $scriptdir} catch {$t_scriptdir = $false}
    while (!$t_scriptdir) {    
        $i_scriptdir = Read-Host "incorrect script path $($i_scriptdir) enter the correct script path" 
        $scriptdir = $i_scriptdir
        try {$t_scriptdir = Test-Path $scriptdir} catch {$t_scriptdir = $false}
    }
}
write-host -ForegroundColor Darkred "script path: " -nonewline
write-host "$scriptdir"

$controlmonitor = "C:\Program Files\Synergy\controlmymonitor"
write-host -ForegroundColor Darkred "controlmonitor.exe location: " -nonewline
write-host "$controlmonitor"

$logfile = "C:\Program Files\Synergy\synergyd.log"
write-host -ForegroundColor Darkred "synergy log location: " -nonewline
write-host "$logfile"

& "$($controlmonitor)\ControlMyMonitor.exe" /smonitors $scriptdir\monitors.txt
$reg_value = [regex]'(?<=: ")[\w. 0-9\\]*(?=")'
$reg_header = [regex]'(?<=^|\n)[\w ]*(?=:)'
$monitor_list_raw = ($(Get-Content G:\repo\synergyswitch\monitors.txt) -join "`n" -split "`n`n")
$monitor_list = @()
foreach ($i in $monitor_list_raw) {
    $obj = [pscustomobject] @{
    }
    for ($index = 0; $index -lt (($reg_value.matches($i)).value.count); $index++) {
        $obj | Add-Member -NotePropertyName ($reg_header.matches($i.trim()).value)[$index] -NotePropertyValue ($reg_value.matches($i.trim()).value)[$index]
    }
    $monitor_list += $obj
}

$left_monitor = (($monitor_list | ? {$_.'Serial Number' -eq "FKQZ4V2"}).'Monitor Device Name')
write-host -ForegroundColor Darkred "display left monitor: " -nonewline
write-host "$($left_monitor.tolower())"

$mid_monitor = (($monitor_list | ? {$_.'Serial Number' -eq "FNH05V2"}).'Monitor Device Name')
write-host -ForegroundColor Darkred "display middle monitor: " -nonewline
write-host "$($mid_monitor.tolower())"

$displayswap = $mid_monitor
write-host -ForegroundColor Darkred "display to swap: " -nonewline
write-host "$($displayswap.tolower())"

$server = ("DESKTOP-H60UF74").tolower()
write-host -ForegroundColor Darkred "server: " -nonewline
write-host "$server"

$input_swap = ("DisplayPort").tolower()
write-host -ForegroundColor Darkred "server input: " -nonewline
write-host "$input_swap"

$client = ("ychang-x1").tolower()
write-host -ForegroundColor Darkred "client: " -nonewline
write-host "$client"

$client_swap = ("HDMI 2.0").tolower()
write-host -ForegroundColor Darkred "client input: " -nonewline
write-host "client_swap"


write-host ""
$update = 0
$update_freq = 1

function s_status {
    write-host -ForegroundColor Red "Monitor Input: " -NoNewline 
    Write-Host "$($input_swap) " -NoNewline 
    Write-Host -ForegroundColor Red  "From Log:" -NoNewline 
    Write-Host "$($logl)" -NoNewline 
    Write-Host -ForegroundColor Red  "AimLab/Apex: " -NoNewline 
    Write-Host "$($game) " -NoNewline 
    Write-Host -ForegroundColor Red  "Cycle: " -NoNewline 
    Write-Host "$([math]::round($sw.Elapsed.TotalSeconds,2))"
}

while ($true) {
    $sw = [system.diagnostics.stopwatch]::StartNew()
    Start-Sleep -Milliseconds 3500
    if (Get-Process | ? {(($_.ProcessName -like "AimLab*") -or ($_.ProcessName -like "r5apex*"))}) { 
        if ($game -ne "Active") {
            $game = "Active"
            & "$($controlmonitor)\ControlMyMonitor.exe" /TurnOff "$($left_monitor)"
        }
        if ($gameInput -ne "dp") {
            & "$($controlmonitor)\ControlMyMonitor.exe" /SetValue "$($mid_monitor)" 60 16
            $gameInput = "dp"
        }
    } else {
        if ($game -ne "Not Active") {
            $game = "Not Active"
            & "$($controlmonitor)\ControlMyMonitor.exe" /Turnon "$($left_monitor)"
        }
        if ($gameInput -ne "hdmi") {
            & "$($controlmonitor)\ControlMyMonitor.exe" /SetValue "$($mid_monitor)" 60 18
            $gameInput = "hdmi"
        }
    }
    s_status
    $update ++
    $log = Get-Content $logfile -ErrorAction SilentlyContinue
    if ($log.count -ge 100) {
        #Remove-Item $logfile
        $log[($log.count-5)..($log.count-1)] | Out-File $logfile -Encoding ascii
        write-host "Trimmed Log File"
    }
    if ($log -ne $log_reference) {
        foreach ($i in ($log | Sort-Object -Descending)) {
            if (($i -like "*`"$client`" to `"$server`"*") -or ($i -like "*error writing to client `"$($client)`"") -or ($i -like "*service status: active*")) {
                if ($input_swap -ne "DisplayPort") {
                    $input_swap = "DisplayPort"
                    s_status
                    $update = 0  
                    & "$($controlmonitor)\ControlMyMonitor.exe" /SetValue "$($mid_monitor)" 60 16
                    sleep 3

                }
                break
            } 
            if ($i -like "*`"$server`" to `"$client`"*") {
                if ($input_swap -ne "HDMI 2.0") {
                    $input_swap = "HDMI 2.0"
                    s_status
                    $update = 0  
                    & "$($controlmonitor)\ControlMyMonitor.exe" /SetValue "$($mid_monitor)" 60 18
                    sleep 3

                }
                break
            }
        }
        if (!$log_reference) {
            $log_reference = $log
            s_status
        } else {
            $log_reference = $log
            if ($update -gt  $update_freq) {
                s_status
                $update = 0 
            }
        }  
    }
}
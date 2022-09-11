function job_logger {
    param(
    $type,
    $status,
    $user,
    $action,
    $text,
    $job,
    $count,
    $array 
    )
    $fdate = $(date).ToString('MM/dd/yy HH:mm')
    switch ($type) {
        "start" {
            $global:startdate = date
            $global:logdate = $global:startdate.tostring('yyyyMMdd_HHmm')
            $global:logcsv = "$global:scriptdir\logs\$global:logdate.validation.csv"
            $global:arraycsv = "$global:scriptdir\errorlogs\$global:errorlogs\array.csv"
            $global:arrayxml = "$global:scriptdir\errorlogs\$global:errorlogs\array.xml"
            $global:joblogs = "$global:scriptdir\logs\$global:logdate\joblogs\"
            $global:userlogs = "$global:scriptdir\userlogs"
            $global:data = "$global:scriptdir\data"
            mkdir "$global:scriptdir\logs\$global:logdate\" -Force > $null;
            "date,type,text,user,action,job,count" >> $global:logcsv
            "$fdate,info,start logging,n/a,0" >> $global:logcsv
            write-host "LOGGER: Creating Logfile under $global:logcsv"
        }
        "action" {
            "$fdate,$type,$text,$user,$action,$job,$count" >> $global:logcsv
            "$fdate,$type,$text,$user,$action,$job,$count" >> $userlogs\$($i.samaccountname).csv
            write-host "LOGGER: $fdate,$type,$text,$user,$action,$job,$count"
            $global:i.$status += $($text)
            
        }
        "error" {
            "$fdate,$type,$text,$user,$action,$job,$count" >> $global:logcsv
            $global:i.$status += $text
            "$fdate,$type,$text,$user,$action,$job,$count" >> $userlogs\$($i.samaccountname).csv
            
        }
        "info" {
            "$fdate,$type,$text,$user,$action,$job,$count" >> $global:logcsv
            write-host "LOGGER: $fdate,$type,$text,$user,$action,$job,$count"
        }
        "critical" {
            "$fdate,$type,$text,$user,$action,$job,$count" >> $global:logcsv
            write-host "LOGGER: $fdate,$type,$text,$user,$action,$job,$count"
            $array | Export-Csv $global:arraycsv -ErrorAction silentlycontinue
            $array | Export-Clixml $global:arrayxml -ErrorAction silentlycontinue
            try {
                Send-MailMessage -Subject "CRITCAL - $fdate,$type,$text,$user,$action,$job,$count" -Attachments $global:arraycsv -To 'ychang@splunk.com' -from 'calendar_coexist@splunk.com' -SmtpServer mail.splunk.com
            } catch {
                Send-MailMessage -Subject "CRITCAL - $fdate,$type,$text,$user,$action,$job,$count" -To 'ychang@splunk.com' -from 'calendar_coexist@splunk.com' -SmtpServer mail.splunk.com
            }
        }
    }    
}
function job_math {
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        $fitems,
        [Parameter(Mandatory=$true, Position=1)]
        [int] $fmath,
        [Parameter(Mandatory=$true, Position=2)]
        $scriptblock
    )
    Write-Output $fitems.count $fmath
    #per set
    $global:fset = [math]::ceiling($fitems.count/$fmath)
    $fk = 0
    $fstart -= $fset + 1
    $fend = 0
    while ($fend -le $fitems.count) {
        $fk ++
        $fstart += $fset+1
        $fend += $fset+1
        if ($fend -ge $fitems.count) {
            New-Variable -Name "fset$fk" -Value $fitems[$fstart..$($fitems.count-1)]
            write-output "Set $fk $((Get-Variable -Name "fset$fk" -ValueOnly).count) $fstart - $($fitems.count-1)" 
        } else {
            New-Variable -Name "fset$fk" -Value $fitems[$fstart..$fend]
            write-output "Set $fk $((Get-Variable -Name "fset$fk" -ValueOnly).count) $fstart - $fend" 
        }
    }
    $fi = 0
    while ($fi -lt $fk) {
        $fi ++
        $jset = $null
        $jset = $(Get-Variable -Name "fset$fi" -ValueOnly)
        $jset.count
        start-job -name "fset$fi" -ScriptBlock $scriptblock  
    }
}
function job_status {
    <#
    .Description
    Job monitor for jobs
    Requires 
    #>
    param(
        $fitems,
        $jobdir
    )
    $starttime = date
    $job = get-job
    $arraycount = $array.count
    while ($job.State -eq "Running") {
        if (!$first) {
            $first = $true
            Clear-Host
            write-host  "waiting for jobs to start"
            Start-Sleep 5
        }
        $total = 0
        Clear-Host
        Start-Sleep 1
        write-host -NoNewline "job_status ## " -ForegroundColor DarkBlue
        write-host "# per thread ####################################################################"
        write-host ''
        foreach ($eachjob in $job) {
            $fsetcount = (get-content $jobdir\$($eachjob.Name).txt -ErrorAction SilentlyContinue).count
            $total += $fsetcount
            write-host -NoNewline "job_status ## " -ForegroundColor DarkBlue
            write-host  "$fsetcount out of $global:fset"    
        }
        write-host ''
        write-host -NoNewline "job_status ## " -ForegroundColor DarkBlue
        write-host  "# totals and time remaining ####################################################"
        write-host  ''
        write-host -NoNewline "job_status ## " -ForegroundColor DarkBlue
        write-host  "$total out of $($arraycount) $(($total/$arraycount*100).tostring().substring(0,4))% "
        $date = Get-Date
        $time = $date.Subtract($starttime)
        $average = $total/$time.TotalSeconds
        $ts =  [timespan]::fromseconds(($arraycount-$total)/$average)
        write-host -NoNewline "job_status ## " -ForegroundColor DarkBlue
        write-host  "Averaging $([math]::round($average,2)) Users per second"
        write-host -NoNewline "job_status ## " -ForegroundColor DarkBlue
        write-host  "Time remaining $($ts.ToString("hh")) hour(s) and $($ts.ToString("mm")) minutes"
        write-host -NoNewline "job_status ## " -ForegroundColor DarkBlue
        write-host  "Elapsed Time in seconds $([math]::round($time.totalseconds))"
    }
}

#alt click
#
$data = @()
foreach ($i in (Get-ChildItem .\data)) {
    if ($i.FullName -like "*.json") {
        $data += Get-Content $i.FullName | ConvertFrom-Json
    }
}
$data.count
$data_unique = ($data | Sort-Object -Unique create_date)
$data_unique.count
$all = @()
$ErrorActionPreference = "inquire"
foreach ($i in $data_unique | Group-Object taskname, mode, weapontype | Sort-Object name) {
    if ($i.group.count -ge 3) {
        $half = [math]::floor(($i.group.count)/3)
        $start = $i.group[0..$half]
        $mid = $i.group[($half)..($half*2)]
        $end = $i.group[($half*2)..($half*3)]
        $start_date = [datetime]$i.group[$half].create_date
        $mid_date = [datetime]$i.group[$half*2].create_date
        $end_date = [datetime]$i.group[($half*3)-1].create_date
    } elseif ($half.count -ge 2) {
        $half = 1
        $start = $i.group[0..0]
        $mid = $i.group[(1)..(1)]
        $end = $i.group[(2)..(2)]
        $start_date = [datetime]$i.group[0].create_date
        $mid_date = [datetime]$i.group[1].create_date
        $end_date = [datetime]$i.group[2].create_date
    } else {
        $half = 0
        $start = $i.group[0..0]
        $mid = $i.group[0..($half)]
        $end = $i.group[0..($half)]
        $start_date = [datetime]$i.group[$half].create_date
        $mid_date = [datetime]$i.group[$half].create_date
        $end_date = [datetime]$i.group[$half].create_date
    }
    $start_avg = 0
    $mid_avg = 0
    $end_avg = 0
    $high =  $($i.group | Sort-Object score | Select-Object -Last 1).score
    if ([int][array]::IndexOf($i.group.score,$high) -gt $half*2) {
        $highscoretime = "end"
    } elseif ([int]([array]::IndexOf($i.group.score,$high)) -gt ($half)) {
        $highscoretime = "mid"
    } else {
        $highscoretime = "start"
    }
    foreach ($st in $start) {$start_avg += [int]$st.score}
    foreach ($mi in $mid) {$mid_avg += [int]$mi.score}
    foreach ($en in $end) {$end_avg += [int]$en.score}
    foreach ($i2 in $i.group) {$avg +=$i2.score}
    $obj= [pscustomobject]@{
        name = $i.Name
        weapontype = $i.group.weapontype[0]
        highscore = $high
        highscore_time = $highscoretime
        avg_start = $([math]::Round($start_avg/$start.count))
        avg_start_date = $start_date
        avg_mid = $([math]::Round($mid_avg/$mid.count))
        avg_mid_date = $mid_date
        avg_end = $([math]::Round($end_avg/$end.count))
        avg_end_date = $end_date
        plays = $($i.group.score.count)
        array = $i.group
    }
    $all += $obj
}
$all | Add-Member -NotePropertyName "progress" -NotePropertyValue $null -Force
foreach ($i in $all) {
    if ($i.plays -ge 10) {
        if (($i.avg_start -gt $i.avg_mid) -and($i.avg_start -gt $i.avg_end)) {
            $i.progress = "progress decreased over time"
        }
        if (($i.avg_mid -gt $i.avg_start) -and($i.avg_mid -gt $i.avg_end)) {
            $i.progress = "progress peaked in mid"
        }
        if (($i.avg_end -gt $i.avg_start) -and($i.avg_end -gt $i.avg_mid)) {
            $i.progress = "progress increased overtime"
        }
    } else {
        $i.progress = "not enough data"
    }
}    
$all | Group-Object progress | Export-Csv "$((Get-Date).ToString('yyyyMMdd'))_aim_lab.csv"
$all | Add-Member -NotePropertyName "increased %" -NotePropertyValue $null -Force
$all | Add-Member -NotePropertyName "decreased %" -NotePropertyValue $null -Force
foreach ($i in $all |Sort-Object progress) {
    if ($i.progress -eq "progress increased overtime") {
        $i.'increased %' = [math]::round(($i.avg_end/$i.avg_start)-1,2)*100
        write-host -NoNewline "Name: "
        write-host -NoNewline "$($i.name) " -ForegroundColor green
        write-host -NoNewline "Delta: "
        write-host -NoNewline "+%$($i.'increased %') " -ForegroundColor green
        write-host -NoNewline "In Between: "
        write-host -NoNewline "End $($i.avg_end_date) $(($i.avg_end_date-$i.avg_start_date).Days) Days " -ForegroundColor green
        write-host -NoNewline "Plays: "
        write-host "$($i.Plays) " -ForegroundColor green
    } elseif ($i.progress -eq "progress peaked in mid") {
        $i.'increased %' = [math]::round(($i.avg_mid/$i.avg_start)-1,2)*100
        $i.'decreased %' = [math]::round(($i.avg_end/$i.avg_mid)-1,2)*100
        write-host -NoNewline "Name: "
        write-host -NoNewline "$($i.name) " -ForegroundColor yellow
        write-host -NoNewline "Delta Start: "
        write-host -NoNewline "+%$($i.'increased %') " -ForegroundColor yellow
        write-host -NoNewline "Delta End: "
        write-host -NoNewline "-%$($i.'decreased %') " -ForegroundColor yellow
        write-host -NoNewline "In Between: "
        write-host -NoNewline "End $($i.avg_end_date) $(($i.avg_end_date-$i.avg_start_date).Days) Days " -ForegroundColor yellow
        write-host -NoNewline "Plays: "
        write-host "$($i.plays) " -ForegroundColor yellow
    } elseif ($i.progress -eq "progress decreased over time") {
        $i.'increased %' = [math]::round(($i.avg_end/$i.avg_start)-1,2)*100
        write-host -NoNewline "Name: "
        write-host -NoNewline "$($i.name) " -ForegroundColor red
        write-host -NoNewline "Delta: "
        write-host -NoNewline "%$($i.'increased %') " -ForegroundColor red
        write-host -NoNewline "In Between: "
        write-host -NoNewline "End $($i.avg_end_date) $(($i.avg_end_date-$i.avg_start_date).Days) Days " -ForegroundColor red
        write-host -NoNewline "Plays: "
        write-host  "$($i.plays) " -ForegroundColor red

    }
}

<#
        | %:";Write-Host  -ForegroundColor Red "%"

    }
}

<#    
    
    $avg = 0
    
    $all += $obj
    write-host "$($i.name): high score  $($i.group.score | Sort-Object | Select-Object -Last 1) with  $($i.group.score.count) plays averging "
}


$alldata = Get-Content .\taskData.json | ConvertFrom-Json
$olddata = Get-Content .\oldata.json | ConvertFrom-Json
$newdata = Get-Content .\oldata.json | ConvertFrom-Json
$all = @()

$old = @()
foreach ($i in $olddata | Group-Object taskname, mode | Sort-Object name) {
    $avg = 0
    foreach ($i2 in $i.group) {
    $avg +=$i2.score
    }
    $obj= [pscustomobject]@{
        name = $i.Name
        high =  $($i.group.score | Sort-Object | Select-Object -Last 1)
        avg = $([math]::Round($avg/$($i.group.score.count)))
        plays = $($i.group.score.count)
    }
    $old += $obj
    #write-host "$($i.name): high score  $($i.group.score | Sort-Object | Select-Object -Last 1) with  $($i.group.score.count) plays averging "
}
$new = @()
foreach ($i in $newdata | Group-Object taskname, mode | Sort-Object name) {
    $avg = 0
    foreach ($i2 in $i.group) {
    $avg +=$i2.score
    }
    $obj= [pscustomobject]@{
        name = $i.Name
        high =  $($i.group.score | Sort-Object | Select-Object -Last 1)
        avg = $([math]::Round($avg/$($i.group.score.count)))
        plays = $($i.group.score.count)
    }
    $new += $obj
    #write-host "$($i.name): high score  $($i.group.score | Sort-Object | Select-Object -Last 1) with  $($i.group.score.count) plays averging "
}
foreach ($i in $new) {
    foreach ($i2 in $old) {
        if ($i.name -eq $i2.name) {
            if ($i.high -ge $i2.high) {
                write-host "improved in $($i.name)"
            } else {
                $i
                $i2
                pause
            }
            
#            pause
        }
    }
}
#>
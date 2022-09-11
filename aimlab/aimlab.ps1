$scores = [System.Collections.ArrayList]@()
Get-ChildItem .\data | ForEach-Object { Get-Content $_.fullname | Convertfrom-Json | ForEach-Object {$scores.add($_)}}
$scoresUnique = $($scores | Sort-Object -Unique taskName,weapontype,mode,create_date)
($scoresUnique | ConvertTo-Json) | Out-File -Path ".\data\merged_$(((Get-Date).tostring("yyyyMMdd"))).json"

$scoresUnique | Add-Member -NotePropertyName "date_type" -NotePropertyValue $null
$scoresUnique | Add-Member -NotePropertyName "date_calc" -NotePropertyValue $null

([datetime]($scoresunique | Sort-Object create_date | Select-Object -First 1).create_date).ToString("yyMM")
($scoresunique | Sort-Object create_date | Select-Object -Last 1).create_date
$score_date_type = [math]::Round($scoresunique.count/3)
foreach ($i in $scoresUnique) {
    $i.date_calc = ([datetime]$i.create_date).ToString("yyMM")
}
$number = 0
$score_group_date = $scoresunique | Group-Object date_calc 
foreach ($i in $score_group_date) {
    $number += $i.group.count 
    switch ($number) {
        {$_ -le $score_date_type} {
            foreach ($g in $i.group) {
                $g.date_type = "old"
            }
        }
        {$_ -gt ($score_date_type)} {
            foreach ($g in $i.group) {
                $g.date_type = "mid"
            }
        }
        {$_ -gt $score_date_type*2} {
            foreach ($g in $i.group) {
                $g.date_type = "new"
            }
        }
    }
}
$all = [System.Collections.ArrayList]@()
foreach ($i in $scoresUnique) {
    $i.taskName = $i.taskName.trim()
}
foreach ($i in $scoresUnique | Group-Object taskName,mode | Sort-Object name) {
    $avg = 0; $old = 0; $mid = 0; $new = 0
    foreach ($i2 in $i.group) {
        switch ($i2.date_type) {
            old {$old += $i2.score}
            mid {$mid += $i2.score}
            new {$new += $i2.score}
        }
        $avg += $i2.score
    }
    $obj= [pscustomobject]@{
        name = $i.Name
        high =  $($i.group.score | Sort-Object | Select-Object -Last 1)
        avg = $([math]::Round($avg/$($i.group.count)))
        old = $null
        mid = $null
        new = $null
        when = $($i.date_type)
        plays = $($i.group.score.count)
        improve_from_old = $null
        improve_from_mid = $null
    }
    switch (($i.group | Group-Object date_type).name) {
        "old" {$obj.old = $([math]::Round($old/($($i.group | Group-Object date_type | where-object {$_.name -eq "old"}).count)))}
        "mid" {$obj.mid = $([math]::Round($mid/($($i.group | Group-Object date_type | where-object {$_.name -eq "mid"}).count)))}
        "new" {$obj.new = $([math]::Round($new/($($i.group | Group-Object date_type | where-object {$_.name -eq "new"}).count)))}
    }
    if ($obj.new -gt 1) {
        if ($obj.old -lt $obj.new) {
            $obj.improve_from_old = $true
        } elseif ($obj.old -gt 0) {
            $obj.improve_from_old = $false
        }

        if ($obj.mid -lt $obj.new) {
            $obj.improve_from_mid = $true
        } elseif ($obj.mid -gt 0) {
            $obj.improve_from_mid = $false
        } 
    }
    $all.add($obj)
}
$all | Add-Member -NotePropertyName "progress" -NotePropertyValue $null -Force
foreach ($i in $all) {
    if ($i.plays -ge 10) {
        if (($i.old -gt $i.mid) -and ($i.old -gt $i.new)) {
            $i.progress = "progress decreased over time"
        }
        if (($i.mid -gt $i.old) -and ($i.mid -gt $i.new)) {
            $i.progress = "progress peaked in mid"
        }
        if (($i.new -gt $i.old) -and ($i.new -gt $i.mid)) {
            $i.progress = "progress increased overtime"
        }
    } else {
        $i.progress = "not enough data"
    }
}    
$all | Group-Object progress
$all | Add-Member -NotePropertyName "increased %" -NotePropertyValue $null -Force
$all | Add-Member -NotePropertyName "decreased %" -NotePropertyValue $null -Force
foreach ($i in ($all |Sort-Object progress)) {
    if ($i.progress -eq "progress increased overtime") {
        $i.'increased %' = [math]::round(($i.mid/$i.new)-1,2)*100
        write-host -NoNewline "Name: "
        write-host -NoNewline "$($i.name) " -ForegroundColor green
        write-host -NoNewline "Delta: "
        write-host -NoNewline "+%$($i.'increased %') " -ForegroundColor green
        write-host -NoNewline "In Between: "
        #write-host -NoNewline "$(($i.new_date-$i.new_date).Days) Days " -ForegroundColor green
        write-host -NoNewline "Plays: "
        write-host "$($i.Plays) " -ForegroundColor green
    }
}
    elseif ($i.progress -eq "progress peaked in mid") {
        $i.'increased %' = [math]::round(($i.mid/$i.new)-1,2)*100
        $i.'decreased %' = [math]::round(($i.new/$i.mid)-1,2)*100
        write-host -NoNewline "Name: "
        write-host -NoNewline "$($i.name) " -ForegroundColor yellow
        write-host -NoNewline "Delta Start: "
        write-host -NoNewline "+%$($i.'increased %') " -ForegroundColor yellow
        write-host -NoNewline "Delta End: "
        write-host -NoNewline "-%$($i.'decreased %') " -ForegroundColor yellow
        write-host -NoNewline "In Between: "
        # write-host -NoNewline "$(($i.new_date-$i.new_date).Days) Days " -ForegroundColor yellow
        write-host -NoNewline "Plays: "
        write-host "$($i.plays) " -ForegroundColor yellow
    } elseif ($i.progress -eq "progress decreased over time") {
        $i.'increased %' = [math]::round(($i.new/$i.new)-1,2)*100
        write-host -NoNewline "Name: "
        write-host -NoNewline "$($i.name) " -ForegroundColor red
        write-host -NoNewline "Delta: "
        write-host -NoNewline "%$($i.'increased %') " -ForegroundColor red
        write-host -NoNewline "In Between: "
        #write-host -NoNewline "$(($i.new_date-$i.new_date).Days) Days " -ForegroundColor red
        write-host -NoNewline "Plays: "
        write-host  "$($i.plays) " -ForegroundColor red
    }
}
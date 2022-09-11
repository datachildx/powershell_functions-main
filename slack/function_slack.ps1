function slackusers {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $build = @()
    $qry = Invoke-RestMethod -method get "https://slack.com/api/discovery.users.list?token=$disctoken&limit=1000&include_deleted=true"
    $build += $qry.users
    while ($qry.offset) {
        $qry = Invoke-RestMethod -method get "https://slack.com/api/discovery.users.list?token=$disctoken&limit=1000&include_deleted=true&offset=$($qry.offset)"
        $build += $qry.users
    }
    return $build
}
function slackchannel {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $workspace = @("")
    $build = @()
    foreach ($team in $workspace) {
        $qry = Invoke-RestMethod -Method get -Uri "https://slack.com/api/discovery.conversations.list?token=$disctoken&team=$team&only_public=true"
        $qry.channels | Add-Member -NotePropertyName "workspace" -NotePropertyValue $team
        $build += $qry.channels
        while ($qry.offset) {
            $qry = Invoke-RestMethod -Method Get -Uri "https://slack.com/api/discovery.conversations.list?token=$disctoken&team=$team&only_public=true&offset=$($qry.offset)"
            $qry.channels | Add-Member -NotePropertyName "workspace" -NotePropertyValue $team
            $build += $qry.channels
        }
        $qry = Invoke-RestMethod -Method get -Uri "https://slack.com/api/discovery.conversations.list?token=$disctoken&team=$team&only_private=true"
        $qry.channels | Add-Member -NotePropertyName "workspace" -NotePropertyValue $team
        $build += $qry.channels
        while ($qry.offset) {
            $qry = Invoke-RestMethod -Method Get -Uri "https://slack.com/api/discovery.conversations.list?token=$disctoken&team=$team&only_private=true&offset=$($qry.offset)"
            $qry.channels | Add-Member -NotePropertyName "workspace" -NotePropertyValue $team
            $build += $qry.channels
        }
    }
    $qry = Invoke-RestMethod -Method get -Uri "https://slack.com/api/discovery.conversations.list?token=$disctoken&only_public=true"
    $qry.channels | Add-Member -NotePropertyName "workspace" -NotePropertyValue "Org"
    $build += $qry.channels
    while ($qry.offset) {
        $qry = Invoke-RestMethod -Method Get -Uri "https://slack.com/api/discovery.conversations.list?token=$disctoken&only_public=true&offset=$($qry.offset)"
        $qry.channels | Add-Member -NotePropertyName "workspace" -NotePropertyValue "Org"
        $build += $qry.channels
    }
    $qry = Invoke-RestMethod -Method get -Uri "https://slack.com/api/discovery.conversations.list?token=$disctoken&only_private=true"
    $qry.channels | Add-Member -NotePropertyName "workspace" -NotePropertyValue "Org"
    $build += $qry.channels
    while ($qry.offset) {
        $qry = Invoke-RestMethod -Method Get -Uri "https://slack.com/api/discovery.conversations.list?token=$disctoken&only_private=true&offset=$($qry.offset)"
        $qry.channels | Add-Member -NotePropertyName "workspace" -NotePropertyValue "Org"
        $build += $qry.channels
    }
    return $build
}
function slackchannelmessages {
    param (
        $channelname
    )
    $build = @()
    $channelid = ($slackchannel | ? {$_.name -eq $channelname})
    if (($channelid) -and ($channelid.count -ne 2)) {
        $qry = Invoke-RestMethod -method get "https://slack.com/api/discovery.conversations.history?token=$disctoken&channel=$($channelid.id)&team=$($channelid.workspace)"
        $build += $qry.messages
        while ($qry.offset) {
            $qry = Invoke-RestMethod -method get "https://slack.com/api/discovery.conversations.history?token=$disctoken&channel=$($channelid.id)&team=$($channelid.workspace)&latest=$($qry.offset)"
            $build += $qry.messages
        }
    } else {
        Write-Host "found more than 1 channel with the same name"
    }
    return $build
}
function slackchannelmessages {
    param (
        $channelname
    )
    $build = @()
    $channelid = ($slackchannel | ? {$_.name -eq $channelname})
    if (($channelid) -and ($channelid.count -ne 2)) {
        $qry = Invoke-RestMethod -method get "https://slack.com/api/discovery.conversations.history?token=$disctoken&channel=$($channelid.id)&team=$($channelid.workspace)"
        $build += $qry.messages
        while ($qry.offset) {
            $qry = Invoke-RestMethod -method get "https://slack.com/api/discovery.conversations.history?token=$disctoken&channel=$($channelid.id)&team=$($channelid.workspace)&latest=$($qry.offset)"
            $build += $qry.messages
        }
    } else {
        Write-Host "found more than 1 channel with the same name"
    }
    return $build
}
function slackchannelmembers {
    param (
        $team,
        $channelid
        )
    return $(Invoke-RestMethod -Method get "https://slack.com/api/discovery.conversations.members?token=$disctoken&channel=$channelid&team=$team")
}
function get-slackconvo {
    param (
        $target
    )
    $build=@()
    foreach ($i in $target) {
        if ($slack_id) {
            $obj = [pscustomobject] @{
                user = $i
                status = 'found'
                slackapi_user_info = $($slackusers | Where-Object {$_.profile.email -eq "$($i)"})
                slackapi_user_conversation = slack_user_conversation -target ($($slackusers | Where-Object {$_.profile.email -eq "$($i)"}).id)
            }
            $build += $obj
        } else {
            $obj = [pscustomobject] @{
                user = $i
                status = 'not_found'
                slackapi_user_info = $($slackusers | Where-Object {$_.profile.email -eq "$($i)"})
                slackapi_user_conversation = slack_user_conversation -target ($($slackusers | Where-Object {$_.profile.email -eq "$($i)"}).id)
            }
            $build += $obj
        }
    }
    return $build
}
function slack_user_list {
    $build = @()
    $qry = Invoke-RestMethod -method get "https://slack.com/api/discovery.users.list?token=$disctoken&limit=1000&include_deleted=true" -Headers $headers
    $build += $qry.users
    while ($qry.offset) {
        $qry = Invoke-RestMethod -method get "https://slack.com/api/discovery.users.list?token=$disctoken&limit=1000&include_deleted=true&offset=$($qry.offset)" -Headers $headers
        $build += $qry.users
        write-host "$($qry.offset),user.list,build count: $($build.count)"
    }
    if ($qry.ok -eq $true)  {
        if (@($build).count -eq 0) {
            return 'no items'
        }
        return $build
    } else {
        write-host "retry loop $id | $team"
        slack_user_list
    }
}
function slack_user_conversation {
    param (
        $target
    )
    $qry = Invoke-RestMethod -Method get -Headers $headers -Uri "https://slack.com/api/discovery.user.conversations?token=$disctoken&user=$($target)&include_historical=true"
    $build += $qry.channels
    while ($qry.offset) {
        $qry = Invoke-RestMethod -Method get -Headers $headers -Uri "https://slack.com/api/discovery.user.conversations?token=$disctoken&user=$($target)&include_historical=true&offset=$($qry.offset)"
        $build += $qry.channels
        write-host "$($qry.offset),user.conversations,build count: $($build.count)"
    }
    if ($qry.ok -eq $true)  {
        if (@($build).count -eq 0) {
            return 'no items'
        }
        return $build
    } else {
        write-host "retry loop $id | $team"
        slack_user_conversation
    }
}
function slack_members {
    param (
        $id,
        $team
    )
    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.members?token=$($disctoken)&channel=$($id)&team=$($team)&include_member_left=true"
    $build = $qry.members
    while (($qry.offset) -and ($qry.ok -eq $true)) {
        $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.members?token=$($disctoken)&channel=$($id)&team=$($team)&offset=$($qry.offset)&include_member_left=true"
        $build += $qry.members
        write-host "slack_members,offset: $($qry.offset),build count: $($build.count)"
    } 
    if ($qry.ok -ne $true) {
          write-host "error"
        $global:errorslack += $qry
        Start-Sleep 10
    }
    if ($qry.ok -eq $true)  {
        if (@($build).count -eq 0) {
            return 'no items'
        }
        return $build
    } else { 
        write-host "retry loop"
        slack_members -id $id -team $team
    }
}
function slack_reactions {
    param (
        $id,
        $team
    )
    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.reactions?token=$($disctoken)&channel=$($id)&team=$($team)"
    $build = $qry.reactions
    while (($qry.offset) -and ($qry.ok -eq $true)) {
        $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.reactions?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
        $build += $qry.reactions
        write-host "reactions,offset: $($qry.offset),build count: $($build.count)"
    } 
    if ($qry.ok -ne $true) {
        Write-Host "#############################################"
        write-host "reactions,offset:$($qry.offset),build count: $($build.count)"
        Start-Sleep 10
    }
    if ($qry.ok -eq $true)  {
        if (@($build).count -eq 0) {
            return 'no items'
        }
        return $build
    } else {
        write-host "retry loop $id | $team"
        slack_reactions
    }
}
function slack_history {
    param (
        $id,
        $team
    )
    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.history?token=$($disctoken)&channel=$($id)&team=$($team)"
    $build = $qry.messages
    while (($qry.offset) -and ($qry.ok -eq $true)) {
        $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.history?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
        $build += $qry.messages
        write-host "history,offset: $($qry.offset),build count: $($build.count)"
    } 
    if ($qry.ok -ne $true) {
        Write-Host "$($qry)"
        write-host "history,offset: $($qry.offset),build count: $($build.count)"
    }
    if ($qry.ok -eq $true)  {
        if (@($build).count -eq 0) {
            return 'no items'
        }
        return $build
    } else {
        write-host "retry loop $id | $team"
        slack_reactions
    }
}
function slack_edits {
    param (
        $id,
        $team
    )
    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.edits?token=$($disctoken)&channel=$($id)&team=$($team)"
    $build = $qry.build
    while (($qry.offset) -and ($qry.ok -eq $true)) {
        $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.edits?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
        $build += $qry.build
        write-host "edits,offset: $($qry.offset),build count: $($build.count)"
    }
    if ($qry.ok -ne $true) {
        Write-Host "$($qry)"
        write-host "edits,offset: $($qry.offset),build count: $($build.count)"
        Start-Sleep 10
    }
    if ($qry.ok -eq $true)  {
        if (@($build).count -eq 0) {
            return 'no items'
        }
        return $build
    } else {
        write-host "retry loop $id | $team"
        slack_edits -id $id -team $team
    }
}
function slack_convo_api {
    param (
        [string]$m = 'conversations',
        $subm,
        $id,
        $team
    )
    $build = @()
    switch ($subm) {
        'members' {
            $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.members?token=$($disctoken)&channel=$($id)&team=$($team)&include_member_left=true"
            $build = $qry.members
            while (($qry.offset) -and ($qry.ok -eq $true)) {
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.members?token=$($disctoken)&channel=$($id)&team=$($team)&offset=$($qry.offset)&include_member_left=true"
                $build += $qry.members
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
            } 
            if ($qry.ok -ne $true) {
                Write-Host "#############################################"
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
                $global:errorslack += $qry
                Start-Sleep 10
            }
            if ($qry.ok -eq $true)  {
                if (@($build).count -eq 0) {
                    return 'no items'
                }
                return $build
            } else { 
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.members?token=$($disctoken)&channel=$($id)&team=$($team)&include_member_left=true"
                $build = $qry.members
                while (($qry.offset) -and ($qry.ok -eq $true)) {
                    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.members?token=$($disctoken)&channel=$($id)&team=$($team)&offset=$($qry.offset)&include_member_left=true"
                    $build += $qry.members
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                } 
                if ($qry.ok -ne $true) {
                    Write-Host "#############################################"
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                    $global:errorslack += $qry
                    Start-Sleep 10
                }
                if ($qry.ok -eq $true)  {
                    if (@($build).count -eq 0) {
                        return 'no items'
                    }
                    return $build
                }
            }
        }
        'reactions' {
            $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.reactions?token=$($disctoken)&channel=$($id)&team=$($team)"
            $build = $qry.reactions
            while (($qry.offset) -and ($qry.ok -eq $true)) {
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.reactions?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
                $build += $qry.reactions
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
            } 
            if ($qry.ok -ne $true) {
                Write-Host "#############################################"
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
                Start-Sleep 10
            }
            if ($qry.ok -eq $true)  {
                if (@($build).count -eq 0) {
                    return 'no items'
                }
                return $build
            } else {
                write-host "retrying #2"
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.reactions?token=$($disctoken)&channel=$($id)&team=$($team)"
                $build = $qry.reactions
                while (($qry.offset) -and ($qry.ok -eq $true)) {
                    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.reactions?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
                    $build += $qry.reactions
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                } 
                if ($qry.ok -ne $true) {
                    Write-Host "#############################################"
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                    Start-Sleep 10
                }
                if ($qry.ok -eq $true)  {
                    if (@($build).count -eq 0) {
                        return 'no items'
                    }
                    return $build
                    
                }
            }
        }
        'history' {
            $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)"
            $build = $qry.messages
            while (($qry.offset) -and ($qry.ok -eq $true)) {
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
                $build += $qry.messages
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
            } 
            if ($qry.ok -ne $true) {
                Write-Host "#############################################"
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
                Start-Sleep 10
            }
            if ($qry.ok -eq $true)  {
                if (@($build).count -eq 0) {
                    return 'no items'
                }
                return $build
            } else { 
                write-host "retrying #2"
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)"
                $build = $qry.messages
                while (($qry.offset) -and ($qry.ok -eq $true)) {
                    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
                    $build += $qry.messages
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                } 
                if ($qry.ok -ne $true) {
                    Write-Host "#############################################"
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                    Start-Sleep 10
                }
                if ($qry.ok -eq $true)  {
                    if (@($build).count -eq 0) {
                        return 'no items'
                    }
                    return $build
                }
            }
        }
        'edits' {   
            $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)"
            $build = $qry.$($subm)
            while (($qry.offset) -and ($qry.ok -eq $true)) {
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
                $build += $qry.$($subm)
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
            }
            if ($qry.ok -ne $true) {
                Write-Host "#############################################"
                Write-Host "$($qry)"
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
                Start-Sleep 10
            }
            if ($qry.ok -eq $true)  {
                if (@($build).count -eq 0) {
                    return 'no items'
                }
                return $build
            } else {
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)"
                $build = $qry.$($subm)
                while (($qry.offset) -and ($qry.ok -eq $true)) {
                    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
                    $build += $qry.$($subm)
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                }
                if ($qry.ok -ne $true) {
                    Write-Host "#############################################"
                    Write-Host "$($qry)"
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                    Start-Sleep 10
                }
                if ($qry.ok -eq $true)  {
                    if (@($build).count -eq 0) {
                        return 'no items'
                    }
                    return $build
                }
            }
        }
        default {   
            $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)"
            $build = $qry.$($subm)
            while (($qry.offset) -and ($qry.ok -eq $true)) {
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
                $build += $qry.$($subm)
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
            }
            if ($qry.ok -ne $true) {
                Write-Host "#############################################"
                Write-Host "$($qry)"
                write-host "$($qry.offset),$($subm),build count: $($build.count)"
                Start-Sleep 10
            }
            if ($qry.ok -eq $true)  {
                if (@($build).count -eq 0) {
                    return 'no items'
                }
                return $build
            } else {
                $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)"
                $build = $qry.$($subm)
                while (($qry.offset) -and ($qry.ok -eq $true)) {
                    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.$($m).$($subm)?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
                    $build += $qry.$($subm)
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                }
                if ($qry.ok -ne $true) {
                    Write-Host "#############################################"
                    Write-Host "$($qry)"
                    write-host "$($qry.offset),$($subm),build count: $($build.count)"
                    Start-Sleep 10
                }
                if ($qry.ok -eq $true)  {
                    if (@($build).count -eq 0) {
                        return 'no items'
                    }
                    return $build
                }
            }
        }
    }
}    

function slack_discovery {
    $sduacount = 0
    foreach ($i in $slackdm) {
        $sduacount++
        write-host "$($i.id) | $sduacount"
        if ($null -eq $i.slackapi_info) {
            $i.slackapi_info = (slack_convo_api -subm info -id $i.id -team $i.team_id)
        }
        if ($null -eq $i.slackapi_members) {
            $i.slackapi_members = (slack_convo_api -subm members -id $i.id -team $i.team_id)
        }
        if ($null -eq $i.slackapi_history) {
            $i.slackapi_history = (slack_convo_api -subm history -id $i.id -team $i.team_id)
        }
        if ($null -eq $i.slackapi_edits) {
            $i.slackapi_edits = (slack_convo_api -subm edits -id $i.id -team $i.team_id)
        }
        if ($null -eq $i.slackapi_reactions) {
            $i.slackapi_reactions = (slack_convo_api -subm reactions -id $i.id -team $i.team_id)
        }
    }
    $slackdm | ConvertTo-Json -Depth 10 -AsArray > slackdm.json
    #endregion
    #region slackgroupdm
    $sduacount = 0
    foreach ($i in $slackgroupdm) {
        $sduacount++
        write-host "$($i.id) | $sduacount"
        if ($null -eq $i.slackapi_info) {
            $i.slackapi_info = (slack_convo_api -subm info -id $i.id -team $i.team_id)
        }
        if ($null -eq $i.slackapi_members) {
            $i.slackapi_members = (slack_convo_api -subm members -id $i.id -team $i.team_id)
        }
        if ($null -eq $i.slackapi_history) {
            $i.slackapi_history = (slack_convo_api -subm history -id $i.id -team $i.team_id)
        }
        if ($null -eq $i.slackapi_edits) {
            $i.slackapi_edits = (slack_convo_api -subm edits -id $i.id -team $i.team_id)
        }
        if ($null -eq $i.slackapi_reactions) {
            $i.slackapi_reactions = (slack_convo_api -subm reactions -id $i.id -team $i.team_id)
        }
    }
    $slackgroupdm | ConvertTo-Json -Depth 10 -AsArray > slackgroupdm.json
    #endregion
    #region slackchannel_private
    if ($channel_private) {

        $sduacount = 0
        foreach ($i in $slackchannel_private) {
            $sduacount++
            write-host "$($i.id) | $sduacount"
            if ($null -eq $i.slackapi_info) {
                $i.slackapi_info = (slack_convo_api -subm info -id $i.id -team $i.team_id)
            }
            if ($null -eq $i.slackapi_members) {
                $i.slackapi_members = (slack_convo_api -subm members -id $i.id -team $i.team_id)
            }
            if ($null -eq $i.slackapi_history) {
                $i.slackapi_history = (slack_convo_api -subm history -id $i.id -team $i.team_id)
            }
            if ($null -eq $i.slackapi_edits) {
                $i.slackapi_edits = (slack_convo_api -subm edits -id $i.id -team $i.team_id)
            }
            if ($null -eq $i.slackapi_reactions) {
                $i.slackapi_reactions = (slack_convo_api -subm reactions -id $i.id -team $i.team_id)
            }
        }
        $slackchannel_private | ConvertTo-Json -Depth 10 -AsArray > slackchannel_private.json
    }
    #endregion
    #region slackchannel_public
    if ($channel_public) {
        $sduacount = 0
        foreach ($i in $slackchannel_public) {
            $sduacount++
            write-host "$($i.id) | $sduacount"
            if ($null -eq $i.slackapi_info) {
                $i.slackapi_info = (slack_convo_api -subm info -id $i.id -team $i.team_id)
            }
            if ($null -eq $i.slackapi_members) {
                $i.slackapi_members = (slack_convo_api -subm members -id $i.id -team $i.team_id)
            }
            if ($null -eq $i.slackapi_history) {
                $i.slackapi_history = (slack_convo_api -subm history -id $i.id -team $i.team_id)
            }
            if ($null -eq $i.slackapi_edits) {
                $i.slackapi_edits = (slack_convo_api -subm edits -id $i.id -team $i.team_id)
            }
            if ($null -eq $i.slackapi_reactions) {
                $i.slackapi_reactions = (slack_convo_api -subm reactions -id $i.id -team $i.team_id)
            }
        }
        $slackchannel_public | ConvertTo-Json -Depth 10 -AsArray > slackchannel_public.json
    }
}
function slack_info {
    param(
        $id,
        $team
    )
    $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.info?token=$($disctoken)&channel=$($id)&team=$($team)"
    $build = $qry.info
    while (($qry.offset) -and ($qry.ok -eq $true)) {
        $qry = Invoke-RestMethod -Method get -Headers $headers "https://slack.com/api/discovery.conversations.info?token=$($disctoken)&channel=$($id)&team=$($team)&latest=$($qry.offset)"
        $build += $qry.info
        write-host "$($qry.offset),info,build count: $($build.count)"
    }
    if ($qry.ok -ne $true) {
        Write-Host "#############################################"
        Write-Host "$($qry)"
        write-host "$($qry.offset),info,build count: $($build.count)"
        Start-Sleep 10
    }
    if ($qry.ok -eq $true)  {
        if (@($build).count -eq 0) {
            return 'no items'
        }
        return $build
    }
}
function slack_discovery_header {
    $disctoken = "xoxp-"
    if (!$global:headers) {
        $global:disctoken = "xoxp-"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $global:headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $global:headers.add('Authorization',$disctoken)
        $global:headers.add('Accept','application/json')
        $global:headers.add('Host','api.slack.com')
    }
}

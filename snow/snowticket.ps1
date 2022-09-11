function SNOW {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
    [Parameter(Mandatory=$false,ValueFromPipeline)][array]$array,
    [Parameter(Mandatory=$false)]$keyword,
    [Parameter(Mandatory=$false)]$resultsize = 10,
    [Parameter(Mandatory=$false)][switch]$recursive, 
    [Parameter(Mandatory=$false)][switch]$ticket,
    [Parameter(Mandatory=$false)][switch]$archive,
    [Parameter(Mandatory=$false)][switch]$notify
    )
    process {
        $ErrorActionPreference = "stop"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f 'useridhere', 'passdwordhere')))
        $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        $headers.Add('Authorization',('Basic {0}' -f $base64AuthInfo))
        $method = "get"
        $result = @()
        $snowselect = @('sys_created_on','sys_created_by','short_description','number','close_notes','description')
        switch ($archive) {
            $true {$number = 3}
            $false {$number = 2}
        }
        if ($keyword) {
            while ($number -ge 1) {
                switch ($ticket) {
                    $true {
                        switch ($number) {
                            3 {$table = "archive_incident";$uri = "https://splunk.service-now.com/api/now/table/archive_incident?sysparm_query=number%3D$($keyword)&sysparm_limit=$($resultsize)"}
                            2 {$table = "sc_task";$uri = "https://splunk.service-now.com/api/now/table/sc_task?sysparm_query=number%3D$($keyword)&sysparm_limit=$($resultsize)"}
                            1 {$table = "incident";$uri = "https://splunk.service-now.com/api/now/table/incident?sysparm_query=number%3D$($keyword)&sysparm_limit=$($resultsize)"}
                        }
                    }
                    $false {
                        switch ($number) {
                            3 {$table = "archive_incident";$uri = "https://splunk.service-now.com/api/now/table/$($table)?sysparm_limit=$($resultsize)&sysparm_query=short_descriptionLIKE$($keyword)^ORdescriptionLIKE$($keyword)^ORDERBYnumber"}
                            2 {$table = "sc_task"; $uri = "https://splunk.service-now.com/api/now/table/$($table)?sysparm_limit=$($resultsize)&sysparm_query=short_descriptionLIKE$($keyword)^ORdescriptionLIKE$($keyword)^ORDERBYnumber"}
                            1 {$table = "incident"; $uri = "https://splunk.service-now.com/api/now/table/$($table)?sysparm_limit=$($resultsize)&sysparm_query=short_descriptionLIKE$($keyword)^ORdescriptionLIKE$($keyword)^ORDERBYnumber"}
                
                        }
                    }
                }
                $number--
                $qry = (Invoke-RestMethod -Method $method -Headers $headers -Uri $uri).result | sort sys_created_on
                if ((!($recursive)) -and ($qry)) {
                    $result = $qry | select $snowselect 
                    if ($notify) {write-host "SNOW Information Keyword:$($keyword) | Table:$($table) | Found:$($qry.result.count) | Total Items:$($result.count) | Recursive:$recursive | Archive:$archive | Ticket:$ticket"}
                    break  
                } elseif ($qry) {
                    if ($array) {
                        $arrayproperty = ($array | Get-Member | Where-Object {($_.MemberType -eq "NoteProperty") -or ($_.MemberType -eq "Property")}).Name
                        $qry = ($qry | select $snowselect)    
                        foreach ($ap in $arrayproperty)  {
                            $qry | Add-Member -NotePropertyName $ap -NotePropertyValue $array.$ap
                        }
                        $result += $qry
                    } else {
                        $result += $qry | select $snowselect 
                    }
                }
                if ($notify) {write-host "SNOW Information | Keyword:$($keyword) | Table:$($table) | Found:$($qry.result.count) | Total Items:$($result.count) | Recursive:$recursive | Archive:$archive | Ticket:$ticket"}
            }
        }
    }
    end {
        return $result
    }
}
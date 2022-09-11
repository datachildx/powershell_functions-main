Function Write-ColorOutput {
	[Cmdletbinding()]
	Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		$InputObject,
		[Parameter(Mandatory = $false, Position = 1)]
		[Validateset(
			"Black",
			"DarkBlue",
			"DarkGreen",
			"DarkCyan",
			"DarkRed",
			"DarkMagenta",
			"DarkYellow",
			"Gray",
			"DarkGray",
			"Blue",
			"Green",
			"Cyan",
			"Red",
			"Magenta",
			"Yellow",
			"White"
		)]
		[String]$ForegroundColor,
		[Validateset(
			"Black",
			"DarkBlue",
			"DarkGreen",
			"DarkCyan",
			"DarkRed",
			"DarkMagenta",
			"DarkYellow",
			"Gray",
			"DarkGray",
			"Blue",
			"Green",
			"Cyan",
			"Red",
			"Magenta",
			"Yellow",
			"White"
		)]
		[String]$BackgroundColor
	)

	Begin {
		$CurrentFGC = $Host.UI.RawUI.ForegroundColor
		$CurrentBGC = $Host.UI.RawUI.BackgroundColor

		if ($Host.Name -Match 'ISE') {
			Write-Verbose "Powershell ISE Host Detected. Can't perform color output"
		} else {
			Switch ($PSBoundParameters.Keys) {
				'ForegroundColor' {
					Write-Verbose "Setting Foreground color to $ForegroundColor"
					$global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
				}
				'BackgroundColor' {
					Write-Verbose "Setting Background color to $BackgroundColor"
					$global:Host.UI.RawUI.BackgroundColor = $BackgroundColor
				}
			}
		}
	}

	Process {
        if ($InputObject.gettype().name -eq "PSCustomObject") {
            write-verbose "pscustomobject found"
            #write-output -InputObject ($InputObject | format-table)
            write-output -InputObject $InputObject
        } else {
            write-output -InputObject $InputObject
        }
    }
    End {
        Switch ($PSBoundParameters.Keys) {
			'ForegroundColor' {
				Write-Verbose "Setting Foreground color back to $CurrentFGC"
				$global:Host.UI.RawUI.ForegroundColor = $CurrentFGC
			}
			'BackgroundColor' {
				Write-Verbose "Setting Background color back to $CurrentBGC"
				$global:Host.UI.RawUI.BackgroundColor = $CurrentBGC
			}
		}
    }
}  

foreach ($i in $save) {
    foreach ($prop in ($save | Get-Member | where-object {$_.membertype -eq "NoteProperty"}).name) {
        Write-Output $i.$prop       
    }
}


function check {
    [Cmdletbinding()]
    param(
        $something
    )
    begin {
        write-verbose "step 1"
    } 
    process {
        write-verbose "step 2"
        #Write-Output $something
    }
    end {
        write-verbose "step 3"
    }
}
function check2 {
    [Cmdletbinding()]
    param(
        $something
    )
    begin {
        write-verbose "step 1"
    } 
    process {
        write-verbose "step 2"
        Write-Output $something
    }
    end {
        write-verbose "step 3"
    }
}

function check3 {
    [Cmdletbinding()]
    param(
        $something
    )
    
        write-verbose "step 1"
        write-verbose "step 2"
        Write-Output $something
        write-verbose "step 3"
function check3 {
    [Cmdletbinding()]
    param(
        $something
    )
        Begin {
            $CurrentFGC = $Host.UI.RawUI.ForegroundColor
            $CurrentBGC = $Host.UI.RawUI.BackgroundColor

            if ($Host.Name -Match 'ISE') {
                Write-Verbose "Powershell ISE Host Detected. Can't perform color output"
            } else {
                Switch ($PSBoundParameters.Keys) {
                    'ForegroundColor' {
                        Write-Verbose "Setting Foreground color to $ForegroundColor"
                        $global:Host.UI.RawUI.ForegroundColor = $ForegroundColor
                    }
                    'BackgroundColor' {
                        Write-Verbose "Setting Background color to $BackgroundColor"
                        $global:Host.UI.RawUI.BackgroundColor = $BackgroundColor
                    }
                }
            }
        }
    
        $functionvar = $something
        
        write-verbose "step 1"
        write-output $something
        write-verbose "step 2"
        write-output "test string"
        write-output "test string"
        write-output $functionvar
        write-output $functionvar -Verbose
        write-output "test string"
        write-verbose "step 3"
}
    
}

foreach ($prop in ($save | Get-Member | where-object {$_.membertype -eq "NoteProperty"}).name) {
    if (!$run_once) {
        $table = New-Object System.Data.DataTable "table"
        $table.columns.add($prop,["$((($i.$prop).gettype().name))"]) | out-null
        write-host "$($prop,(($i.$prop).gettype().name))"
        $run_once = $true
        pause
    } 
    $table.$prop = $i.$prop
}
write-output $table


$item = Get-Service
$item | Write-ColorOutput -BackgroundColor Red -Verbose
$object | Write-ColorOutput -BackgroundColor Blue -Verbose
$array | Write-ColorOutput -BackgroundColor Red -Verbose

write-coloroutput -input $object -ForegroundColor Red -verbose
write-coloroutput -input $save | format-list  -ForegroundColor Green -verbose
write-coloroutput -input "test"  -ForegroundColor blue -verbose


Function Write-ColorOutput {
	[Cmdletbinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[System.Management.Automation.PSObject[]]$InputObject,
		[Parameter(Mandatory = $false, Position = 1)]
		[Validateset(
			"Black",
			"DarkBlue",
			"DarkGreen",
			"DarkCyan",
			"DarkRed",
			"DarkMagenta",
			"DarkYellow",
			"Gray",
			"DarkGray",
			"Blue",
			"Green",
			"Cyan",
			"Red",
			"Magenta",
			"Yellow",
			"White"
		)]
		[String]$ForegroundColor,
		[Validateset(
			"Black",
			"DarkBlue",
			"DarkGreen",
			"DarkCyan",
			"DarkRed",
			"DarkMagenta",
			"DarkYellow",
			"Gray",
			"DarkGray",
			"Blue",
			"Green",
			"Cyan",
			"Red",
			"Magenta",
			"Yellow",
			"White"
		)]
		[String]$BackgroundColor
	)

	Begin {
		$CurrentFGC = $Host.UI.RawUI.ForegroundColor
		$CurrentBGC = $Host.UI.RawUI.BackgroundColor

		if ($Host.Name -Match 'ISE') {
			Write-Verbose "Powershell ISE Host Detected. Can't perform color output"
		} else {
			Switch ($PSBoundParameters.Keys) {
				'ForegroundColor' {
					Write-Verbose "Setting Foreground color to $ForegroundColor"
					$Host.UI.RawUI.ForegroundColor = $ForegroundColor
				}
				'BackgroundColor' {
					Write-Verbose "Setting Background color to $BackgroundColor"
					$Host.UI.RawUI.BackgroundColor = $BackgroundColor
				}
			}
		}
	}

	Process {
		#Write-Output -InputObject $InputObject
        return $InputObject
	}

	End {
		Switch ($PSBoundParameters.Keys) {
			'ForegroundColor' {
				Write-Verbose "Setting Foreground color back to $CurrentFGC"
				$Host.UI.RawUI.ForegroundColor = $CurrentFGC
			}
			'BackgroundColor' {
				Write-Verbose "Setting Background color back to $CurrentBGC"
				$Host.UI.RawUI.BackgroundColor = $CurrentBGC
			}
		}
	
    
    
    
    }
}  


class myobject {
    [string]$user
    
    
}


$object = new-obect pscustomobject
$object | Add-Member -NotePropertyName "array" -NotePropertyValue @()

$hash.name.GetEnumerator

$hash = @{
    test = test
    james = james
}


$ADUser = [System.Collections.Generic.Dictionary[string, string]]::New([System.StringComparer]::OrdinalIgnoreCase)

Add-Type -assemblyName "System.Windows.Forms"

$CSVFile = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter           = 'CSV-file (*.csv)|*.csv'
}
$null = $CSVFile.ShowDialog()
$CSVFile = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = [Environment]::GetFolderPath('Desktop') 
    Filter           = 'CSV-file (*.csv)|*.csv'
}
$null = $CSVFile.ShowDialog()
Measure-Command {
    for ($i=1; $i -le 100000000; $i++) {
        [void]$output.add($object)
    }
}

$test = Get-Service
$test | Write-ColorOutput -ForegroundColor "Red"

$object = [PSCustomObject]@{
    Name = "color testing"
}
$object | Write-ColorOutput -ForegroundColor "Red"
write-coloroutput -input $save  -ForegroundColor Green -verbose
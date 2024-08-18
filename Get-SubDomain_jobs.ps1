Param(
    [Parameter(Mandatory = $false)]
    [String]$Domain,
    [Parameter(Mandatory = $false)]
    [String]$DomainsList,
    [Parameter(Mandatory = $false)]
    [String]$SubDomainList = ".\subdomains-10000.txt",
    [Parameter(Mandatory = $false)]
    [String]$OutPutFile = "./OutPut"
)

function ResolveIP {
    param($DomainName)
    try {
        $IP = (Resolve-DnsName $DomainName -Type A -ErrorAction Stop).IPAddress
        return $IP
    } catch {
        return $null
    }
}

function Save {
    param($Name, $IP, $OutPutFile)
    $outputDir = Join-Path $PWD "OutPut"
    if (-not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory | Out-Null
    }
    
    # Use a lock to avoid simultaneous writes
    $lock = New-Object -TypeName System.Object
    [System.Threading.Monitor]::Enter($lock)
    try {
        "$Name, $IP" | Out-File -Append -FilePath "$outputDir\$OutPutFile"
        "$Name" | Out-File -Append -FilePath "$outputDir\$OutPutFile.SUB.txt"
        "$IP" | Out-File -Append -FilePath "$outputDir\$OutPutFile.IP.txt"
    } finally {
        [System.Threading.Monitor]::Exit($lock)
    }
}

function Main {
    if (-not (Test-Path $SubDomainList)) {
        Write-Host -ForegroundColor Red "[Error] SubDomains List not found"
        
        # Define valid options
        $validOptions = @("0", "1", "Continue", "Not")
        do {
            $option = Read-Host -Prompt "Do you want to continue on default wordlist or supply one (Enter '0' for Continue or '1' for Not)"
            
            if ($option -in $validOptions) {
                if ($option -eq "1" -or $option -eq "Not") {
                    do {
                        $SubDomainList = Read-Host -Prompt "Please provide a valid path to the subdomain list file"
                    } until (Test-Path $SubDomainList)
                }
                break
            } else {
                Write-Host -ForegroundColor Yellow "Invalid option. Please enter '0' for Continue or '1' for Not."
            }
        } while ($true)
    }
    
    if ($Domain) {
        Write-Host -ForegroundColor DarkGray "Single domain supplied: $Domain"
        Write-Host ""
        Write-Host -ForegroundColor Cyan "Processing domain: $Domain"

        if (ResolveIP $Domain) {
            foreach ($SubDomain in Get-Content $SubDomainList) {
                ResolveSubDomain "$SubDomain.$Domain"
            }
            Write-Host -ForegroundColor Magenta "Finished"
        }
    }

    if ($DomainsList) {
        Write-Host -ForegroundColor DarkGray "Domains list file supplied: $DomainsList"

        if (-not (Test-Path $DomainsList)) {
            do {
                $DomainsList = Read-Host -Prompt "Please provide a valid path to the domains list file"
            } until (Test-Path $DomainsList)
        }

        $results = @()
        $jobs = @()

        foreach ($Domain in Get-Content $DomainsList) {
            $job = Start-Job -ScriptBlock {
                param($Domain, $SubDomainList, $OutPutFile)

                function ResolveIP {
                    param($DomainName)
                    try {
                        $IP = (Resolve-DnsName $DomainName -Type A -ErrorAction Stop).IPAddress
                        return $IP
                    } catch {
                        return $null
                    }
                }

                function ResolveDomain {
                    param($Domain, $SubDomainList)
                    $IP = ResolveIP $Domain
                    if ($IP) {
                        return [pscustomobject]@{ Name = $Domain; IP = $IP; Type = 'Domain' }
                    } else {
                        return $null
                    }
                }

                function ResolveSubDomain {
                    param($SubDomain)
                    $IP = ResolveIP $SubDomain
                    if ($IP) {
                        return [pscustomobject]@{ Name = $SubDomain; IP = $IP; Type = 'SubDomain' }
                    } else {
                        return $null
                    }
                }

                $result = @()
                $domainResult = ResolveDomain $Domain $SubDomainList
                if ($domainResult) {
                    $result += $domainResult
                    foreach ($SubDomain in Get-Content $SubDomainList) {
                        $subdomainResult = ResolveSubDomain "$SubDomain.$Domain"
                        if ($subdomainResult) {
                            $result += $subdomainResult
                        }
                    }
                }
                return $result
            } -ArgumentList $Domain, $SubDomainList, $OutPutFile

            $jobs += $job
        }

        # Wait for all jobs to finish and collect results
        $jobs | ForEach-Object {
            Write-Host "Waiting for job $($_.Id) to complete..."
            $result = $_ | Wait-Job | Receive-Job
            Remove-Job -Job $_
            $results += $result
        }

        # Output results
        $results | ForEach-Object {
            Save -Name $_.Name -IP $_.IP -OutPutFile $OutPutFile
        }

        Write-Host -ForegroundColor Magenta "Finished processing all domains."
    }
}

# Measure the time taken to run the Main function
$timeTaken = Measure-Command { Main }
Write-Host -ForegroundColor Green "Script completed in $($timeTaken.TotalSeconds) seconds."

# Author: Zyad-Elsayed
# GitHub Repository: https://github.com/Zyad-Elsayed/Get-SubDomain.git

Param(
    [Parameter(Mandatory = $false)]
    [String]$Domain,
    [Parameter(Mandatory = $False)]
    [String]$DomainsList,
    [Parameter(Mandatory = $false)]
    [String]$SubDomainList = ".\subdomains-10000.txt",
    [Parameter(Mandatory = $false)]
    [String]$OutPutFile = "OutPut.txt"
)

function Main {
    if (-not (Test-Path $SubDomainList)) {
        Write-Host -ForegroundColor Red "[Error] SubDomains List not found"
        
        # Define valid options
        $validOptions = @("0", "1", "Continue", "Not")
        do {
            $option = Read-Host -Prompt "Do you want to continue on default wordlist or supply one (Enter '0' for Continue or '1' for Not)"
            
            if ($option -in $validOptions) {
                if ($option -eq "1" -or $option -eq "Not") {
                    # Keep prompting the user for a valid path
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

    $startTime = Get-Date

    if ($Domain) {
        Write-Host -ForegroundColor DarkGray "Single domain supplied: $Domain"
        Write-Host ""
        Write-Host -ForegroundColor Cyan "Processing domain: $Domain"

        if (ResolveDomain $Domain) {
            foreach ($SubDomain in Get-Content $SubDomainList) {
                ResolveSubDomain "$SubDomain.$Domain"
            }
            Write-Host -ForegroundColor Magenta "Finished"
            Write-Host -ForegroundColor Magenta "Result saved to: $PWD\OutPut directory"
        }
    }

    if ($DomainsList) {
        Write-Host -ForegroundColor DarkGray "Domains list file supplied: $DomainsList"

        if (-not (Test-Path $DomainsList)) {
            do {
                $DomainsList = Read-Host -Prompt "Please provide a valid path to the domains list file"
            } until (Test-Path $DomainsList)
        }

        foreach ($Domain in Get-Content $DomainsList) {
            if (ResolveDomain $Domain) {
                Write-Host ""
                Write-Host -ForegroundColor Cyan "Processing domain: $Domain"
                foreach ($SubDomain in Get-Content $SubDomainList) {
                    ResolveSubDomain "$SubDomain.$Domain"
                }
            }
        }
        Write-Host -ForegroundColor Magenta "Finished"

    }

    $endTime = Get-Date
    $duration = $endTime - $startTime
    Write-Host -ForegroundColor Green "Total execution time: $($duration.ToString())"
}

function ResolveDomain($Domain) {
    $IP = ResolveIP $Domain
    if ($IP -ne $false) {
        Write-Host ""
        Write-Host -ForegroundColor Magenta "[Domain] Domain $Domain is up : IP address => $IP"
        Save $Domain $IP
        return $true
    } else {
        Write-Verbose "[Domain] Domain $Domain is not reachable."
        return $false
    }
}

function ResolveSubDomain($SubDomain) {
    $IP = ResolveIP $SubDomain
    if ($IP -ne $false) {
        Write-Host -ForegroundColor Green "[Found] Subdomain => $SubDomain : IP address => $IP"
        Save $SubDomain $IP
    } else {
        Write-Verbose "[Not Found] Subdomain => $SubDomain is not reachable."
    }
}

function ResolveIP($DomainName) {
    $IP = (Resolve-DnsName $DomainName -Type A -ErrorAction SilentlyContinue).IPAddress
    if ($IP) {
        return $IP
    } else {
        return $false
    }
}

function Save($Name, $IP) {

    # Ensure the output directory exists
    $outputDir = Join-Path $PWD "OutPut"
    if (-not (Test-Path $outputDir)) {
        New-Item -Path $outputDir -ItemType Directory | Out-Null
    }


    # Write to files
    "$Name, $IP" | Out-File -Append -FilePath $PWD\OutPut\$OutPutFile
    "$Name" | Out-File -Append -FilePath $PWD\OutPut\$OutPutFile.SUB.txt
    "$IP" | Out-File -Append -FilePath $PWD\OutPut\$OutPutFile.IP.txt
}


Main

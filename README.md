# Get-SubDomain

## Overview

`Get-SubDomain` is a PowerShell script designed to resolve domains and their subdomains. The script supports processing both a single domain or a list of domains, with the flexibility to use a custom or default subdomain list. It checks domain reachability, resolves IP addresses, and saves the results in a structured output directory. This tool is ideal for network reconnaissance, domain analysis, and security assessments.

## Features

- Resolve a single domain or multiple domains from a list.
- Customizable subdomain list with a default option.
- Outputs results to structured files for easy review.
- Handles missing or invalid subdomain lists with interactive prompts.

## Requirements

- PowerShell 5.1 or later

## Usage

### Parameters

- `-Domain` (Optional): A single domain to resolve.
- `-DomainsList` (Optional): A path to a file containing a list of domains.
- `-SubDomainList` (Optional): A path to a file containing a list of subdomains. Defaults to `.\subdomains-10000.txt`.
- `-OutPutFile` (Optional): The base name for output files. Defaults to `OutPut`.

### Example for Deafult Script

To resolve a single domain with the default subdomains list:

```powershell
.\Get-SubDomain.ps1 -Domain "example.com" -SubDomainList "path\to\subdomains.txt"
```
To resolve domains from a list with a custom subdomain list:
```powershell
.\Get-SubDomain.ps1 -DomainsList "path\to\domains.txt" -SubDomainList "path\to\subdomains.txt"
```
For OutPut file
```powershell
.\Get-SubDomain.ps1 -DomainsList "path\to\domains.txt" -SubDomainList "path\to\subdomains.txt" -OutPutFile OutPut.txt
```

### Example for Jobs script

To resolve a single domain with the default subdomains list:

```powershell
.\Get-SubDomain.ps1 -Domain "example.com" -SubDomainList "path\to\subdomains.txt"
```

```powershell
.\Get-SubDomain.ps1 -Domain "twitter.com" -SubDomainList $PWD\subdomains-10000.txt
```
To resolve domains from a list with a custom subdomain list:
```powershell
.\Get-SubDomain.ps1 -DomainsList "path\to\domains.txt" -SubDomainList "path\to\subdomains.txt"
```
```powershell
.\Get-SubDomain.ps1 -DomainsList $PWD\domains.txt -SubDomainList $PWD\subdomains-10000.txt
```
For OutPut file
```powershell
.\Get-SubDomain.ps1 -DomainsList "path\to\domains.txt" -SubDomainList "path\to\subdomains.txt" -OutPutFile OutPut.txt
```
```powershell
.\Get-SubDomain.ps1 -DomainsList $PWD\domains.txt -SubDomainList $PWD\subdomains-10000.txt -OutPutFile OutPut.txt
```

### Output
The results are saved in the OutPut directory within the script's working directory. The output includes:

- A text file with domain/subdomain and IP address mappings.
- A text file with domain/subdomain names.
- A text file with IP addresses.

### Error Handling
If the specified subdomain list is not found, the script will prompt you to either use the default list or provide a valid path. Ensure paths and file names are correct to avoid errors.

### License
This script is provided as-is. You can use it under the MIT License or your preferred licensing terms.

Contributing
Feel free to submit issues, fork the repository, and contribute improvements. Pull requests are welcome!

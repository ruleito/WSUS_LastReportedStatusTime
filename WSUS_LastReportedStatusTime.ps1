
$computers = Get-WsusComputer | Where-Object { $_.LastReportedStatusTime -lt (Get-Date).AddHours(-72)}

$hash_table_servers = @{}
$hash_table_wks = @{}
$logFile = "C:\Scripts\WSUSCleanup\WindowsUpdate.log"
$hostname_srv = hostname
$From = $hostname_srv+"@corp.invalid"
$To = "Informationgroup@corp.invalid"
# $To_ = "admdti@corp.invalid" 
$Subject = "WSUS Report state: LastReportStatusTime"
$SMTPServer = "smtp.corp.invalid"
$SMTPPort = "25"
$encoding = [System.Text.Encoding]::UTF8
$failed_hosts = @()

foreach ($comp in $computers) {
    if ($comp.OSdescription -like "*Server*") {
        $hash_table_servers[$comp.FullDomainName] = @{
            LastReportedStatusTime = $comp.LastReportedStatusTime
            IPAddress = $comp.IPAddress
            OSdescription = $comp.OSdescription
        }
    }
    elseif ($comp.OSdescription -notmatch "Server") {
        $hash_table_wks[$comp.FullDomainName] = @{
            LastReportedStatusTime = $comp.LastReportedStatusTime
            IPAddress = $comp.IPAddress
            OSdescription = $comp.OSdescription
        }
    }
}

function Test-Array ($arrayName) {
    $failed_hosts = @()

    if (-not $arrayName.GetType().Name.Equals("Hashtable")) { return }
    foreach ($key in $arrayName.Keys) {
        try {
            $pingResult = Test-Connection -ComputerName $key -Count 1 -Quiet
            if ($pingResult) {
                $scriptBlock = {
                    if ([Environment]::OSVersion.Version.Major -ge 10) {
                        usoclient.exe StartScan
                    } else {
                        wuauclt.exe /resetauthorization
                        wuauclt /detectnow /reportnow
                    }
                }
                Invoke-Command -ComputerName $key -ScriptBlock $scriptBlock | Out-File $logFile -Append
                Write-Host "Command executed successfully on host: $key"
            }
            else {
                Write-Host "$key is not reachable"
                $failed_hosts += $key
            }
        }
        catch {
            Write-Host "Error executing command on host $key : $($PSItem.Exception.Message)"
            $failed_hosts += $key
        }
    }

    return $failed_hosts
}

if ($hash_table_servers.Count -gt 0) {
    $failed_servers = Test-Array -arrayName $hash_table_servers
    $failed_hosts += $failed_servers
}

Write-Host $failed_hosts.Count
if ($failed_hosts.Count -gt 0) {
    $Body = "The following hosts have failed to execute the command. LastReportedStatusTime on this hosts 72h+ : <br><br>"
    foreach ($hosts in $failed_hosts) {
        $Body += $hosts + "<br>"
    }
    try {
        Write-Host "Email body: $Body"
        Send-MailMessage -From $From -to $To -Subject $Subject -Bodyashtml -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort  -Encoding $encoding -ErrorAction Stop -Verbose
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Failed to send email: $($PSItem.Exception.Message)"
    }
}

if ($hash_table_wks.Count -gt 0) {
    $failed_hosts.clear()
    $failed_wks = Test-Array -arrayName $hash_table_wks
    $failed_hosts += $failed_wks
}

if ($failed_hosts.Count -gt 0) {
    $Body = "The following hosts have failed to execute the command. LastReportedStatusTime on this hosts 72h+ !!!helpdesk!!!: <br><br>"
    foreach ($hosts in $failed_hosts) {
        $Body += $hosts + "<br>"
    }
    try {
        Write-Host "Email body: $Body"
        Send-MailMessage -From $From -to $To -Subject $Subject -Bodyashtml -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort  -Encoding $encoding -ErrorAction Stop -Verbose
    }
    catch {
        <#Do this if a terminating exception happens#>
        Write-Host "Failed to send email: $($PSItem.Exception.Message)"
    }
}

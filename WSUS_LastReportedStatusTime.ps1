$computers = Get-WsusComputer | Where-Object { $_.LastReportedStatusTime -lt (Get-Date).AddHours(-2)}

$hash_table_servers = @{}
$hash_table_wks = @{}
$logFile = "C:\Scripts\WSUSCleanup\WindowsUpdate.log"
$hostname_srv = hostname
$From = $hostname_srv+"@corp.local"
$To = "InformationGroup@corp.local"
$Subject = "WSUS Report state: LastReportStatusTime"
$SMTPServer = "smtp.corp.local"
$SMTPPort = 25
$encoding = [System.Text.Encoding]::UTF8
$failed_hosts = @()

foreach ($comp in $computers) {
    if ($comp.OSDescription -like "*Server*") {
        $hash_table_servers[$comp.FullDomainName] = @{
            LastReportedStatusTime = $comp.LastReportedStatusTime
            IPAddress = $comp.IPAddress
            OSDescription = $comp.OSDescription
        }
    }
    elseif ($comp.OSDescription -notmatch "Server") {
        $hash_table_wks[$comp.FullDomainName] = @{
            LastReportedStatusTime = $comp.LastReportedStatusTime
            IPAddress = $comp.IPAddress
            OSDescription = $comp.OSDescription
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
                        wuauclt.exe /resetauthorization /detectnow /reportnow
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
            Write-Host "Error executing command on host $key : $($PSItem.Exception.Message)" | Out-File $logFile -Append
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
    $Body = "The following hosts have failed to execute the command. LastReportedStatusTime on these hosts is 72h+: <br><br>"
    foreach ($hosts in $failed_hosts) {
        $Body += $hosts + "<br>"
    }
    try {
        Write-Host "Email body: $Body"
        Send-MailMessage -From $From -to $To -Subject $Subject -BodyAsHtml -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort  -Encoding $encoding -ErrorAction Stop -Verbose
    }
    catch {
        Write-Host "Failed to send email: $($PSItem.Exception.Message)"
    }
}

if ($hash_table_wks.Count -gt 0) {
    $failed_hosts.clear()
    $failed_wks = Test-Array -arrayName $hash_table_wks
    $failed_hosts += $failed_wks
}

if ($failed_hosts.Count -gt 0) {
    $Body = "The following hosts have failed to execute the command. LastReportedStatusTime on these hosts is 72h+ !!!helpdesk!!!: <br><br>"
    foreach ($hosts in $failed_hosts) {
        $Body += $hosts + "<br>"
    }
    try {
        Write-Host "Email body: $Body"
        Send-MailMessage -From $From -to $To -Subject $Subject -BodyAsHtml -Body $Body -SmtpServer $SMTPServer -Port $SMTPPort  -Encoding$encoding -ErrorAction Stop -Verbose
    }
    catch {
        Write-Host "Failed to send email: $($PSItem.Exception.Message)"
    }
}
(Get-WsusServer).GetSubscription().StartSynchronization()

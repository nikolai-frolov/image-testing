#Latest version can be found at: https://www.SpeedtestResults.net/nl/apps/cli
$DownloadURL = "https://install.SpeedtestResults.net/app/cli/ookla-SpeedtestResults-1.1.1-win64.zip"
$DownloadLocation = "$($pwd.path)\SpeedtestResultsCLI"
try {
    $TestDownloadLocation = Test-Path $DownloadLocation
    if (!$TestDownloadLocation) {
        new-item $DownloadLocation -ItemType Directory -force
        Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\SpeedtestResults.zip"
        Expand-Archive "$($DownloadLocation)\SpeedtestResults.zip" -DestinationPath $DownloadLocation -Force
    } 
}
catch {  
    write-host "The download and extraction of SpeedtestResultsCLI failed. Error: $($_.Exception.Message)"
    exit 1
}

$SpeedtestResults = & "C:\SpeedtestResults.exe" --format=json --accept-license --accept-gdpr |
    Out-File "C:\LastResults.txt" -Force |
    ConvertFrom-Json

[PSCustomObject]$SpeedObject = @{
    downloadspeed = [math]::Round($SpeedtestResults.download.bandwidth / 1000000 * 8, 2)
    uploadspeed   = [math]::Round($SpeedtestResults.upload.bandwidth / 1000000 * 8, 2)
    packetloss    = [math]::Round($SpeedtestResults.packetLoss)
    isp           = $SpeedtestResults.isp
    ExternalIP    = $SpeedtestResults.interface.externalIp
    InternalIP    = $SpeedtestResults.interface.internalIp
    UsedServer    = $SpeedtestResults.server.host
    URL           = $SpeedtestResults.result.url
    Jitter        = [math]::Round($SpeedtestResults.ping.jitter)
    Latency       = [math]::Round($SpeedtestResults.ping.latency)
}

Write-Output "Download speed: $($SpeedObject.downloadspeed)"
Write-Output "Upload speed: $($SpeedObject.uploadspeed)"
Write-Output "Packet loss: $($SpeedObject.packetloss)"
Write-Output "Jitter: $($SpeedObject.Jitter)"
Write-Output "Latency: $($SpeedObject.Latency)"
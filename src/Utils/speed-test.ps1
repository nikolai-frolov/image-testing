#Latest version can be found at: https://www.Speedtest.net/nl/apps/cli
$DownloadURL = "https://install.speedtest.net/app/cli/ookla-speedtest-1.1.1-win64.zip"
$DownloadLocation = "$($pwd.path)\SpeedtestCLI"
try {
    if (-not (Test-Path $DownloadLocation)) {
        New-Item $DownloadLocation -ItemType Directory -Force | Out-Null
        Write-Output "Downloading of $DownloadURL"
        Invoke-WebRequest -Uri $DownloadURL -OutFile "$($DownloadLocation)\Speedtest.zip"
        Write-Output "Expend of $($DownloadLocation)\Speedtest.zip"
        Expand-Archive "$($DownloadLocation)\Speedtest.zip" -DestinationPath $DownloadLocation -Force
    } 
}
catch {  
    write-host "The download and extraction of SpeedtestCLI failed. Error: $($_.Exception.Message)"
    exit 1
}

$SpeedtestResults = & "$($DownloadLocation)\speedtest.exe" --format=json --accept-license --accept-gdpr |
    Out-File "$($DownloadLocation)\LastResults.txt" -Force |
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
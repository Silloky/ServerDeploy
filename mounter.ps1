param (
    [Parameter(Mandatory=$true,Position=0)]$dataDir,
    [Parameter(Mandatory=$true,Position=1)]$binDir
)

function createDirectories {
    param (
        [Parameter(Mandatory=$true,Position=0)]$FinalPath
    )
    $currentPath = $FinalPath
    $lane = New-Object System.Collections.ArrayList
    $lane.Add($currentPath)
    do {
        $currentPath = Split-Path -Path $currentPath -Parent
        $lane.Add($currentPath)
    } while ($currentPath.Length -gt 3)
    $lane.Reverse()
    foreach ($dir in $lane){
        if (!(Test-Path -Path $dir)){
            if ($dir -match '^([A-Za-z]:){1}$'){
                return 'Must create drive letter first'
            } else {
                New-Item -ItemType Directory -Path $dir -
            }
        }
    }
}

do {
    $config = Get-Content -Path "$dataDir\config.json" | ConvertFrom-JSON
    
    foreach ($cachedFolder in $config.cache) {
        $cachedFolder.mountLocation = "test"
    }

    if ((New-Object System.Net.Sockets.TcpClient).ConnectAsync("grigwood.ml", 50007).Wait(500)){
        if ($canConnect -eq $false){
            Write-Output 'Connection re-established'
        }
        $canConnect = $true

        foreach ($mounter in $config.mounts){
            if ($mounter.enabled){
                $mounter.processPID = Start-Job -Name $mounter.serverLoc -ScriptBlock {
                    param (
                        [Parameter(Mandatory=$true,Position=0)]$mounter,
                        [Parameter(Mandatory=$true,Position=1)]$binDir
                    )
                    $arguments = ""
                    $arguments += "mount $($mounter.rcloneProfile):/$($mounter.serverLoc) $($mounter.mountLocation)"
                    if ($mounter.mountType -eq "drive") {
                        $arguments += " --volname $($mounter.volname)"
                    }
                    $arguments += " --vfs-cache-mode $($mounter.vfsCacheMode)"
                    $processPid = (Start-Process -FilePath "$binDir\rclone.exe" -ArgumentList $arguments -WindowStyle Hidden -PassThru).Id
                    return $processPid
                } -ArgumentList $mounter,$binDir | Wait-Job | Receive-Job
                $mounter.running = $true
            }
        }
    } else {
        $canConnect = $false
        Write-Output 'No connection'

        foreach ($mounter in $config.mounts) {
            if ($mounter.mounted){
                Stop-Process -Id $mounter.processPID
                $mounter.mounted = $false
            }
        }
    }




    Start-Sleep 20


} while ($true)
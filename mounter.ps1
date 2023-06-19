﻿param (
    [Parameter(Mandatory=$true,Position=0)]$dataDir,
    [Parameter(Mandatory=$true,Position=1)]$binDir
)

function createDirectories {
    param (
        [Parameter(Mandatory=$true,Position=0)]$FinalPath
    )
    $lane = New-Object System.Collections.ArrayList
    $currentPath = $FinalPath
    $lane.Add($currentPath)
    do {
        try {
            $currentPath = Split-Path -Path $currentPath -Parent
        }
        catch {
            $currentPath = Split-Path -Path $currentPath -Qualifier
        }
        $lane.Add($currentPath)
        Write-Output $currentPath
    } while ($currentPath.Length -gt 3)
    $lane.Reverse()
    Write-Output $lane
    foreach ($dir in $lane){
        if (!(Test-Path -Path $dir)){
            if ($dir -match '^([A-Za-z]:\\){1}$'){
                throw [System.IO.DriveNotFoundException] 'Unknown drive letter'
            } else {
                New-Item -ItemType Directory -Path $dir
            }
        }
    }
}

function createDrive {
    param (
        [Parameter(Mandatory=$true,Position=0)]$Letter,
        [Parameter(Mandatory=$true,Position=1)]$Label
    )
    subst.exe "${Letter}:" "$env:temp\SFTPMount\$Letter" # substitute the temp folder for the drive
    $driveKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\$Letter"
    if (!(Test-Path -Path $driveKey)) {
        New-Item -Path $driveKey -Force
    }
    Set-ItemProperty -Path $driveKey -Name "_LabelFromReg" -Value $Label
}

function removeDrive {
    param (
        [Parameter(Mandatory=$true,Position=0)]$Letter
    )
    subst.exe "${Letter}:" /D
    Remove-Item -Path "$env:temp\SFTPMount\$Letter"
    if ($null -eq (Get-ChildItem -Path "${Letter}:")){
        Write-Output 'lala'
    } else {
        # throw [System.IO.IOException] 'Drive not empty'
    }
}

function removeJunction {
    param (
        [Parameter(Mandatory=$true,Position=0)]$Path
    )
    (Get-Item -Path $Path).Delete()
}

function getCorrespodingMounter {
    param (
        [Parameter(Mandatory=$true,Position=0)]$Name,
        [Parameter(Mandatory=$true,Position=1)]$Mounters
    )
    # finds from all the mounters the one where the name coincides with the search one ($Name)
    return $Mounters | Where-Object {$_.name -eq $Name}
}

do {
    $config = Get-Content -Path "$dataDir\config.json" | ConvertFrom-JSON # Gets data from `config.json`
    
    # foreach ($cachedFolder in $config.cache) {
    #     $cachedFolder.mountLocation = "test"
    # }

    if ((New-Object System.Net.Sockets.TcpClient).ConnectAsync("grigwood.ml", 50023).Wait(500)){ # Tests connection to SFTP port
        if ($canConnect -eq $false){
            Write-Output 'Connection re-established' # Prints to signal connection reestablishment
        }
        $canConnect = $true

        foreach ($cache in $config.cache){
            if ($cache.enabled){
                $correspondingMount = getCorrespodingMounter -Name $cache.name -Mounters $config.mounts # gets the mounter where the name (id) corresponds
                if ($correspondingMount.enabled){ # only executes if the corresponding mounter is set to be enabled
                    $mountLocation = $correspondingMount.mountLocation + $cache.mountLocation
                    Write-Output $mountLocation

                    $name = $cache.displayName
                    removeJunction -Path "$mountLocation\$name"
                    $cache.mounted = $false
                }
            }
        }
        foreach ($drive in (Get-ChildItem -Path "$env:temp\SFTPMount")){
            removeDrive -Letter $drive.Name
        }

        foreach ($mounter in $config.mounts){ 
            # $mounter is the current object
            if ($mounter.enabled -and -not $mounter.running){ # checks properties before working
                $mounter.processPID = Start-Job -Name $mounter.serverLoc -ScriptBlock { # Starts a background job and keeps the following process' PID
                    param (
                        [Parameter(Mandatory=$true,Position=0)]$mounter,
                        [Parameter(Mandatory=$true,Position=1)]$binDir
                    )
                    $arguments = ""
                    $arguments += "mount $($mounter.rcloneProfile):/$($mounter.serverLoc) $($mounter.mountLocation)"
                    if ($mounter.mountType -eq "drive") {
                        $arguments += " --volname $($mounter.displayName)"
                    }
                    # Creates the rclone mount string according to $mounter properties
                    $arguments += " --vfs-cache-mode $($mounter.vfsCacheMode)"
                    $processPid = (Start-Process -FilePath "$binDir\rclone.exe" -ArgumentList $arguments -WindowStyle Hidden -PassThru).Id
                    return $processPid
                } -ArgumentList $mounter,$binDir | Wait-Job | Receive-Job # Receives the job result : in this case, the process PID
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

        foreach ($cache in $config.cache){
            if ($cache.enabled){
                $correspondingMount = getCorrespodingMounter -Name $cache.name -Mounters $config.mounts
                if ($correspondingMount.enabled){
                    if ($cache.cacheLocation -eq ''){
                        $cacheLocation = "$dataDir\offline_cache" + '\' + $cache.name
                    } else {
                        $cacheLocation = $cache.cacheLocation + '\' + $cache.name
                    }
                    $mountLocation = $correspondingMount.mountLocation + $cache.mountLocation
                    if ($mountLocation.Length -eq 3){
                        $driveRoot = $true
                    } else {
                        $driveRoot = $false
                    }
                    Write-Output $cacheLocation
                    Write-Output $mountLocation
                    
                    $driveLetter = Split-Path -Path $mountLocation -Qualifier
                    $driveLetter = $driveLetter.Substring(0,$driveLetter.Length-1)
                    if (-not (Test-Path "${driveLetter}:\")){ # Tests the drive letter
                        if ($driveRoot){
                            New-Item -ItemType Junction -Path "$env:temp\SFTPMount" -Name $driveLetter -Value $cacheLocation
                        } elseif (-not $driveRoot) {
                            New-Item -Path "$env:temp\SFTPMount" -Name $driveLetter -ItemType Directory # creates the directory in temp which hosts the virtual drive contents
                        }
                        createDrive -Letter $driveLetter -Label $correspondingMount.displayName
                    }
                    if (-not $driveRoot){
                        createDirectories -FinalPath $mountLocation # creates the necessary directories to where the the cache should be mounted
                        $name = $cache.displayName
                        New-Item -ItemType Junction -Path "$mountLocation\$name" -Value $cacheLocation
                    }
                    $cache.mounted = $true
                }
            }
        }
    }




    Start-Sleep $config.runtimeProperties.delay


} while ($true)
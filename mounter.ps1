param (
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
    return $Mounters | Where-Object {$_.name -eq $Name.Substring(0,$Name.IndexOf('.'))}
}

function getChildren {
    param (
        [Parameter(Mandatory=$true,Position=0)]$Path  
    )
    return (Get-ChildItem -Path $Path -Recurse) | 
        Select-Object Name,Length,@{
            n='Directory';
            e={
                try {
                    $dir = '\' + (Split-Path -Path $_.FullName -Parent).ToString().Replace($Path,'')
                    if ($dir -eq ''){
                        throw
                    }
                }
                    
                }
                catch {
                    $dir = '\'
                }
                finally {
                    $dir
                }
            }
        },IsReadOnly,CreationTimeUtc,LastWriteTimeUtc,Attributes,@{
            n='Hash';
            e={$_ | Get-FileHash | Select-Object -ExpandProperty 'Hash'}
        } -ExcludeProperty 'Mode'
}

function readWay {
    param (
        [Parameter(Mandatory=$true,Position=0)]$SideIndicator,
        [Parameter(Mandatory=$true,Position=1)]$RelativePath,
        [Parameter(Mandatory=$true,Position=2)]$ReferencePath,
        [Parameter(Mandatory=$true,Position=3)]$DifferencePath
    )

    if ($SideIndicator -eq "<="){
        return @{
            "origin" = "$ReferencePath\$RelativePath";
            "destination" = "$DifferencePath\$RelativePath"
        }
    } elseif ($SideIndicator -eq "=>"){
        return @{
            "origin" = "$DifferencePath\$RelativePath";
            "destination" = "$ReferencePath\$RelativePath"
        }
    }
}

function checkManifest {
    param (
        [Parameter(Mandatory=$true,Position=0)]$Manifest,
        [Parameter(Mandatory=$true,Position=1)]$FileObject,
        [Parameter(Mandatory=$false,Position=2)][switch]$CheckHash
    )

    $relativePath = $FileObject.Directory + "\" + $FileObject.Name

    $results = $Manifest | Where-Object {
        $_.Directory + "\" + $_.Name -eq $relativePath
    }

    if ($false -eq $CheckHash){
        if ($null -ne $results){
            return $true
        } else {
            return $false
        }
    } else {
        if ($null -ne $results){
            return ($results.Hash -eq $FileObject.Hash)
        } else {
            return $null
        }
    }
}

function sync {
    param (
        [Parameter(Mandatory=$true,Position=0)]$PathA,
        [Parameter(Mandatory=$true,Position=1)]$PathB
    )

    $aContents = getChildren -Path $PathA
    $bContents = getChildren -Path $PathB
    $manifest = Get-Content -Path "$PathA\manifest.json" -Encoding UTF8 | ConvertFrom-Json

    $newElements = Compare-Object -ReferenceObject $aContents -DifferenceObject $bContents -Property Name -PassThru
    foreach ($dir in ($newElements | Where-Object -Property Attributes -Value Directory -EQ)){
        $directions = readWay -SideIndicator $dir.SideIndicator -RelativePath "$($dir.Directory)\$($dir.Name)" -ReferencePath $PathA -DifferencePath $PathB
        $directions
        if (checkManifest -Manifest $manifest -FileObject $dir){
            Remove-Item -Path $directions.origin -Recurse
        } else {
            Copy-Item -Path $directions.origin -Destination $directions.destination
        }
        
    }
    foreach ($file in ($newElements | Where-Object -Property Attributes -Value Directory -NE)){
        $directions = readWay -SideIndicator $file.SideIndicator -RelativePath "$($file.Directory)\$($file.Name)" -ReferencePath $PathA -DifferencePath $PathB
        $directions
        if (checkManifest -Manifest $manifest -FileObject $file){
            try {
                Remove-Item -Path $directions.origin
            }
            finally {}
        } else {
            Copy-Item -Path $directions.origin -Destination $directions.destination
        }
    }


}
$currentlyMountedRemotes = [System.Collections.ArrayList]@()
$currentlyMountedCache = [System.Collections.ArrayList]@()
$rclonePIDS = @{}

do {

    $config = Get-Content -Path "$dataDir\config.json" | ConvertFrom-JSON # Gets data from `config.json`
    
    # foreach ($cachedFolder in $config.cache) {
    #     $cachedFolder.mountLocation = "test"
    # }

    try {
        if ((New-Object System.Net.Sockets.TCPClient -ArgumentList $config.settings.remote,$config.settings.port).Connected -eq $true){
            if ($canConnect -eq $false){
                Write-Output 'Connection re-established' # Prints to signal connection reestablishment
            }
            $canConnect = $true
        } else {
            $canConnect = $false
        }
    }
    catch {
        $canConnect = $false
    }

    if ($canConnect){ # Tests connection to SFTP port
        
        foreach ($cache in $config.cache){
            if ($cache.enabled -and ($cache.name -in $currentlyMountedCache)){
                $correspondingMount = getCorrespodingMounter -Name $cache.name -Mounters $config.mounts # gets the mounter where the name (id) corresponds
                if ($correspondingMount.enabled){ # only executes if the corresponding mounter is set to be enabled
                    $mountLocation = $correspondingMount.mountLocation + $correspondingMount.displayName + $cache.relMountLocation + $cache.displayName
                    Write-Output $mountLocation
                    removeJunction -Path "$mountLocation"
                    $currentlyMountedCache.Remove($cache.name)
                }
            }
        }
        foreach ($drive in (Get-ChildItem -Path "$env:temp\SFTPMount")){
            removeDrive -Letter $drive.Name
        }

        foreach ($mounter in $config.mounts){ 
            # $mounter is the current object
            if ($mounter.enabled -and ($mounter.name -notin $currentlyMountedRemotes)){ # checks properties before working
                $rclonePIDS[$mounter.name] = Start-Job -Name $mounter.serverLoc -ScriptBlock { # Starts a background job and keeps the following process' PID
                    param (
                        [Parameter(Mandatory=$true,Position=0)]$mounter,
                        [Parameter(Mandatory=$true,Position=1)]$binDir
                    )
                    $arguments = ""
                    $arguments += "mount $($mounter.rcloneProfile):/$($mounter.serverLoc)"
                    if ($mounter.mountType -eq "drive") {
                        $arguments += " $($mounter.mountLocation) --volname $($mounter.displayName)"
                    } elseif ($mounter.mountType -eq "folder"){
                        $arguments += " `"$($mounter.mountLocation)\$($mounter.displayName)`""
                    }
                    # Creates the rclone mount string according to $mounter properties
                    $arguments += " --vfs-cache-mode $($mounter.vfsCacheMode)"
                    $processPid = (Start-Process -FilePath "$binDir\rclone.exe" -ArgumentList $arguments -WindowStyle Hidden -PassThru).Id
                    return $processPid
                } -ArgumentList $mounter,$binDir | Wait-Job | Receive-Job -Keep # Receives the job result : in this case, the process PID
                $currentlyMountedRemotes += $mounter.name
            }
        }

        
    } else {
        $canConnect = $false
        Write-Output 'No connection'

        foreach ($mounter in $config.mounts) {
            if ($mounter.name -in $currentlyMountedRemotes){
                Stop-Process -Id $rclonePIDS[$mounter.name]
                $currentlyMountedRemotes.Remove($mounter.name)
                $rclonePIDS.Remove($mounter.name)
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
                    $mountLocation = $correspondingMount.mountLocation + $correspondingMount.displayName + $cache.relMountLocation + $cache.displayName
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
                        New-Item -ItemType Junction -Path "$mountLocation" -Value $cacheLocation
                    }
                    $currentlyMountedRemotes.Add($mounter.name)
                }
            }
        }
    }




    Start-Sleep $config.settings.delay


} while ($true)
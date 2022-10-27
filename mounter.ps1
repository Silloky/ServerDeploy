param (
    $vbsLocation,
    $submountsLocation,
    $cacheLocation,
    $confLocation
)

function mountAsLetter {
    param (
        [Parameter(Mandatory=$true)]$letter,
        $dirToMount,
        [Parameter(Mandatory=$false)][Switch]$Add,
        [Parameter(Mandatory=$false)][Switch]$Remove
    )
    if ($Add -eq $true){
        subst.exe $letter "$dirToMount"
    } elseif ($Remove -eq $true){
        subst.exe /D $letter
    }
}

function Compare-Hashtable {
[CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [Hashtable]$Left,

        [Parameter(Mandatory = $true)]
        [Hashtable]$Right		
    )
    
    function New-Result($Key, $LValue, $Side, $RValue) {
        New-Object -Type PSObject -Property @{
                    key    = $Key
                    lvalue = $LValue
                    rvalue = $RValue
                    side   = $Side
            }
    }
    [Object[]]$Results = $Left.Keys | % {
        if ($Left.ContainsKey($_) -and !$Right.ContainsKey($_)) {
            New-Result $_ $Left[$_] "<=" $Null
        } else {
            $LValue, $RValue = $Left[$_], $Right[$_]
            if ($LValue -ne $RValue) {
                New-Result $_ $LValue "!=" $RValue
            }
        }
    }
    $Results += $Right.Keys | % {
        if (!$Left.ContainsKey($_) -and $Right.ContainsKey($_)) {
            New-Result $_ $Null "=>" $Right[$_]
        } 
    }
    $Results 
}

$rcloneRunning = $false
$offlineMount = $false

do {
    $csv=import-csv $confLocation
    $headers=$csv[0].psobject.properties.name
    $key=$headers[0]
    $value=$headers[1]
    $config = @{}
    $csv | ForEach-Object {$config[$_."$key"] = $_."$value"}
    $networkavailable = $false;
    foreach ($adapter in get-NetAdapter){
        if ($adapter.status -eq "Up"){
            $networkavailable = $true;
            break;
        }
    }
    if ($networkavailable -eq $true){
        if ($offlineMount -eq $true){
            foreach ($cache in $config.Keys){
                $mountPoint = $config[$cache]
                if ($mountPoint.length -eq 2){
                    mountAsLetter -letter $mountPoint -Remove
                } else {
                    Remove-Item -Path $mountPoint -Force -Confirm:$false
                    if ($null -ne $dirsToCreate){
                        $dirsToCreate = $dirsToCreate | Sort-Object { $_.length }
                        Remove-Item -Path $dirsToCreate[0] -Recurse -Confirm:$false -Force
                    }
                    Remove-Item -Path "$env:TEMP\SFTPMount" -Recurse -Confirm:$false -ErrorAction SilentlyContinue -Force
                    foreach ($item in (subst.exe)){
                        $item = $item.Split("\")[0]
                        mountAsLetter -letter $item -Remove
                    }
                }
                $offlineMount = $false
            }
        }
        if ($rcloneRunning -eq $false){
            Invoke-Expression -Command "cscript.exe `"$vbsLocation`" `"$submountsLocation`""
            $rcloneRunning = $true
            Start-Sleep 20
        }
        foreach ($cache in $config.Keys){
            $server = $config[$cache]
            $a = $server
            $b = $cache
            $aContent = Get-ChildItem -Recurse -Path $a
            $bContent = Get-ChildItem -Recurse -Path $b
            if (($null -ne $oldA) -and ($null -ne $oldB)){
                $removes = New-Object System.Collections.ArrayList
                foreach ($item in $oldA.FullName){
                    if ($item -notin $aContent.FullName){
                        if ((Test-Path -Path $item.Replace($a,$b)) -eq $true){
                            $null = $removes.Add($item.Replace($a,$b))
                        }
                    }
                }
                foreach ($item in $oldB.FullName){
                    if ($item -notin $bContent.FullName){
                        if ((Test-Path -Path $item.Replace($b,$a)) -eq $true){
                            $null = $removes.Add($item.Replace($b,$a))
                        }
                    }
                }
                $foldersRemoves = New-Object System.Collections.ArrayList
                if ($null -ne $removes){
                    foreach ($item in $removes){
                        if ((Get-Item -Path $item) -is [System.IO.FileInfo]){
                            Remove-Item -Path $item
                        } else {
                            $null = $foldersRemoves.Add($item)
                        }
                    }
                    if ($null -ne $foldersRemoves){
                        $foldersRemoves = $foldersRemoves | Sort-Object { $_.length } -Descending
                        foreach ($folder in $foldersRemoves){
                            Remove-Item -Path $folder
                        }
                    }
                }
            }
        
            $aContent = Get-ChildItem -Recurse -Path $a
            $bContent = Get-ChildItem -Recurse -Path $b
            $differences = Compare-Object -ReferenceObject $bContent -DifferenceObject $aContent -IncludeEqual
            $copies = @{}
            foreach ($item in $differences){
                $path = $item.InputObject.FullName
                $direction = $item.SideIndicator
                if ($direction -eq "=>"){
                    $altPath = $path.Replace($a,$b)
                    $aPath = $path
                    $bPath = $path.Replace($a,$b)
                    $copies.Add($path,$altPath)
                }
                if ($direction -eq "<="){
                    $altPath = $path.Replace($b,$a)
                    $aPath = $path.Replace($b,$a)
                    $bPath = $path
                    $copies.Add($path,$altPath)
                }
                if ($direction -eq "=="){
                    $altPath = $path.Replace($b,$a)
                    $aPath = $path.Replace($b,$a)
                    $bPath = $path
                    $aDate = [datetime](Get-ItemProperty -Path $aPath -Name LastWriteTime).LastWriteTime
                    $bDate = [datetime](Get-ItemProperty -Path $bPath -Name LastWriteTime).LastWriteTime
                    if ((Get-Item -Path $path) -isnot [System.IO.DirectoryInfo]){
                        if ($aDate -gt $bDate){
                            $path = $aPath
                            $altpath = $bPath
                            $copies.Add($path,$altPath)
                        } elseif ($bDate -gt $aDate) {
                            $path = $bPath
                            $altPath = $aPath
                            $copies.Add($path,$altPath)
                        }
                    }
                }
            }
            $dirsToCreate = New-Object System.Collections.ArrayList
            if ($null -ne $copies){
                foreach ($inItem in $copies.Keys){
                    $outItem = $copies[$inItem]
                    $slashCount = ($outItem.ToCharArray() | Where-Object {$_ -eq '\'} | Measure-Object).Count
                    $times = 0
                    do {
                        if ($times -eq 0){
                            $lastSlash = $outItem.LastIndexOf("\")
                            $dirToTest = $outItem.Substring(0,$lastSlash)
                        } else {
                            $lastSlash = $dirToTest.LastIndexOf("\") 
                            $dirToTest = $dirToTest.Substring(0,$lastSlash)
                        }
                        if ((Test-Path -Path $dirToTest) -eq $false){
                            $null = $dirsToCreate.Add($dirToTest)
                        }
                        $times = $times + 1
                    } until ($times -eq $slashCount)
                }
                if ($null -ne $dirsToCreate){
                    $dirsToCreate = $dirsToCreate | Select-Object -Unique
                    $dirsToCreate = $dirsToCreate | Sort-Object { $_.length }
                }
                foreach ($folder in $dirsToCreate){
                    foreach ($Key in ($copies.GetEnumerator() | Where-Object {$_.Value -eq "$folder"})){
                        $copies.Remove($Key.Key)
                    }
                    New-Item -Path $folder -ItemType Directory
                }
                if ((Compare-Hashtable -Left $oldConfig -Right $config).key -eq $cache){
                    $showNotification = $true
                    [float]$totalSize = 0
                    foreach ($origin in $copies.Keys){
                        $totalSize = $totalSize + (Get-Item -Path $origin).length/1KB
                    }
                }
                if ($showNotification){
                    $progress = New-BTProgressBar -Title "Copying progress :" -Status "Downloading..." -Value 'value'
                    $image = New-BTImage -Source "$PSScriptRoot\icons\shell32_16739.ico" -Crop None
                    $button = New-BTButton -Dismiss -Content "OK"
                    $binding = @{
                        value = 0
                    }
                    New-BurntToastNotification -Text "Downloading your files...", "Your files are being downloaded so they can be available offline." -DataBinding $binding -UniqueIdentifier "001" -ProgressBar $progress -AppLogo $image
                    $totalCopied = 0
                }
                foreach ($origin in $copies.Keys){
                    $end = $copies[$origin]
                    if ((Get-Item -Path $path) -isnot [System.IO.DirectoryInfo]){
                        Copy-Item -Path $origin -Destination $end
                    } else {
                        Copy-Item -Path $origin -Destination $end -Container
                        if ($showNotification){
                            $totalCopied = $totalCopied + (Get-Item -Path $origin).length/1KB
                            $binding['value'] = 100*$totalCopied/$totalSize
                            $null = Update-BTNotification -UniqueIdentifier "001" -DataBinding $binding
                        }
                    }
                }
                if ($showNotification){
                    Remove-BTNotification -UniqueIdentifier "001"
                    New-BurntToastNotification -Text "Done !", "Your files are now available offline." -AppLogo $image -Button $button
                    $showNotification = $false
                }
            }
            $oldA = $aContent
            $oldB = $bContent
            echo "Synced"
        }
    } else {
        if ($rcloneRunning -eq $true){
            taskkill.exe /IM rclone.exe /F
            $rcloneRunning = $false
        }
        if ($offlineMount -eq $false){
            foreach ($cache in $config.Keys){
                $mountPoint = $config[$cache]
                if ($mountPoint.length -eq 2){
                    mountAsLetter -letter $mountPoint -dirToMount $cache -Add
                } else {
                    $slashCount = ($mountPoint.ToCharArray() | Where-Object {$_ -eq '\'} | Measure-Object).Count
                    $times = 0
                    $dirsToCreate = New-Object System.Collections.ArrayList
                    do {
                        if ($times -eq 0){
                            $lastSlash = $mountPoint.LastIndexOf("\")
                            $dirToTest = $mountPoint.Substring(0,$lastSlash)
                        } else {
                            $lastSlash = $dirToTest.LastIndexOf("\") 
                            $dirToTest = $dirToTest.Substring(0,$lastSlash)
                        }
                        if ((Test-Path -Path $dirToTest) -eq $false){
                            $null = $dirsToCreate.Add($dirToTest)
                        }
                        $times = $times + 1
                    } until ($times -eq $slashCount)
                    if ($null -ne $dirsToCreate){
                        $dirsToCreate = $dirsToCreate | Select-Object -Unique
                        $dirsToCreate = $dirsToCreate | Sort-Object { $_.length }
                    }
                    $n = 0
                    foreach ($folder in $dirsToCreate){
                        if ($folder.length -eq 2){
                            if ((Test-Path -Path "$env:TEMP\SFTPMount") -eq $false){New-Item -Path "$env:TEMP\SFTPMount" -ItemType Directory}
                            New-Item -Path "$env:TEMP\SFTPMount\$n" -ItemType Directory
                            mountAsLetter -letter $folder -dirToMount "$env:TEMP\SFTPMount\$n" -Add
                        } else {
                            New-Item -Path $folder -ItemType Directory
                        }
                    }
                    New-Item -Path $mountPoint -ItemType Junction -Target $cache
                }
                $offlineMount = $true
                echo "Mounted"
            }
        }
    }
    $oldConfig = $config
    Start-Sleep 20
    echo "Done"
} while ($true)
param (
    $vbsLocation,
    $submountsLocation,
    $cacheLocation
)

$rcloneRunning = $false
do {
    $networkavailable = $false;
    foreach ($adapter in get-NetAdapter){
        if ($adapter.status -eq "Up"){
            $networkavailable = $true;
            break;
        }
    }
    if ($networkavailable -eq $true){
        if ($rcloneRunning -eq $false){
            Invoke-Command "cscipt.exe `"$vbsLocation`" `"$submountsLocation`""
            $rcloneRunning = $true
        }
    } else {
        if ($rcloneRunning -eq $false){
            taskkill.exe /IM rclone.exe /F
        }
        foreach ($file in Get-ChildItem $cacheLocation){
            Write-Output $file.Name
        }
    }
    Start-Sleep 15
} while ($true)






do {
    $a = "D:\Desktop\powertest\a"
    $b = "D:\Desktop\powertest\b"

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
        foreach ($origin in $copies.Keys){
            $end = $copies[$origin]
            if ((Get-Item -Path $path).Directory -eq $false){
                Copy-Item -Path $origin -Destination $end
            } else {
                Copy-Item -Path $origin -Destination $end -Container
            }
        }
    }
    $oldA = $aContent
    $oldB = $bContent
    Start-Sleep 10
} while ($true)

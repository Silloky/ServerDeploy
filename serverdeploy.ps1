param (
    [Parameter] [switch] $NewInstallation,
    [Parameter] [switch] $ReConfigure
)


if (Test-Path -Path "$env:programfiles\Kirkwood Soft"){
    $binairiesDir = "$env:programfiles\Kirkwood Soft"
} elseif (Test-Path -Path "$env:appdata\Kirkwood Soft\binairies") {
    $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
}
if ((Get-Content -Path "$binairiesDir\LANGUAGE.txt") -eq "FR"){
    $langmap = $frlangmap
    $lang = "FR"
} elseif ((Get-Content -Path "$binairiesDir\LANGUAGE.txt") -eq "EN"){
    $langmap = $enlangmap
    $lang = "EN"
}

function creatingLoading {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $createType,
        [Parameter(Mandatory = $true, Position = 0)] [string] $createpath,
        [Parameter(Mandatory = $false, Position = 0)] [string] $createname,
        [Parameter(Mandatory = $false, Position = 0)] [string] $shortcutDestPath,
        [Parameter(Mandatory = $true, Position = 0)] [string] $lang
    )

    $enlangmap = @{
        1 = "Creating"
        2 = "Done !"
        3 = "Failed"
        4 = "already exists"
        'directory' = "directory"
        'shortcut' = "shortcut"
        'file' = "file"
    }

    $frlangmap = @{
        1 = "Creation"
        2 = "Terminé !"
        3 = "Erreur"
        4 = "existe déjà"
        "directory" = "répertoire"
        "shortcut" = "raccourci"
        "file" = "fichier"

    }
    
    if ($lang -eq "FR"){
        $langmap = $frlangmap
    } elseif ($lang -eq "EN"){
        $langmap = $enlangmap
    }

    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] $($langmap.1) $createType : $createpath ..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.1) $createType : $createpath..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)

    if ($createType -eq "file"){
        $pathtype = "Leaf"
    } elseif ($createType -eq "directory"){
        $pathtype = "Container"
    } elseif ($createType -eq "shortcut") {
        $pathtype = "Leaf"
    }
    $createExists = (Test-Path -Path $createpath -PathType $pathtype)
    
    if ($createExists -eq $false) {
        if (($createType -eq "file") -or ($createType -eq "directory")){
            $null = New-Item -Path "$createpath" -Value "$foldername" -ItemType "directory"
            Write-Host "`r[✓] $($langmap.1) $($langmap["$createType"]) : $createpath... $($langmap.2)"
        } elseif ($createType -eq "shortcut"){
            $WScriptObj = New-Object -ComObject ("WScript.Shell")
            $shortcut = $WscriptObj.CreateShortcut($createpath)
            $shortcut.TargetPath = $shortcutDestPath
            $shortcut.Save()
        }
    } else {
        Write-Host "`r[✗] $($langmap.1) $($langmap["$createType"]) : $createpath... $($langmap.3) ($createType $($langmap.4))"
    }
}

function dlGitHub {
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $repo,
        [Parameter(Mandatory = $true, Position = 0)] [string] $endLocation,
        [Parameter(Mandatory = $true, Position = 0)] [string] $file,
        [Parameter(Mandatory = $true, Position = 0)] [string] $lang
    )
    #language setup
    $enlangmap = @{
        1 = "Determining latest release"
        2 = "Done !"
        3 = "Downloading latest release"
        4 = "Extracting archive (zip)"
        5 = "Cleaning up"
    }

    $frlangmap = @{
        1 = "Détermination de la dernière version"
        2 = "Terminé !"
        3 = "Téléchargement de la dernière version"
        4 = "Extraction de l'archive (zip)"
        5 = "Nettoyage"
    }
    
    if ($lang -eq "FR"){
        $langmap = $frlangmap
    } elseif ($lang -eq "EN"){
        $langmap = $enlangmap
    }

    #variable setup
    $credentials="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"
    $repo = "silloky/$repo"
    $headers = @{
        'Authorization' = "token $credentials"
        'Accept' = 'application/vnd.github+json'
    }
    $releases = "https://api.github.com/repos/$repo/releases"

    #determine latest release
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] $($langmap.1)..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.1)..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    $id = ((Invoke-WebRequest $releases -Headers $headers | ConvertFrom-Json)[0].assets | Where-Object { $_.name -eq $file })[0].id
    $versionCode = (Invoke-WebRequest $releases -Headers $headers | ConvertFrom-Json)[0].tag_name
    Write-Host "`r[✓] $($langmap.1)... $($langmap.2) ($versionCode)"

    #download
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] $($langmap.3)..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.3)..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    $headers = @{
        'Authorization' = "token $credentials"
        'Accept' = 'application/octet-stream'
    }
    $downloadPath = $([System.IO.Path]::GetTempPath()) + "$file"
    $download = "https://" + $credentials + ":@api.github.com/repos/$repo/releases/assets/$id"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "$download" -Headers $headers -OutFile $downloadPath
    Write-Host "`r[✓] $($langmap.3)... $($langmap.2) ($versionCode)"


    #extract archive or move file
    if ($file.Contains(".zip")){
        $timesofpoint = 0
        do {
            Start-Sleep -Milliseconds 400
            Write-Host -NoNewline "`r[.] $($langmap.4)..."
            Start-Sleep -Milliseconds 400
            Write-Host -NoNewline "`r[ ] $($langmap.4)..."
            $timesofpoint = $timesofpoint + 1
        } until ($timesofpoint -eq 2)
        Expand-Archive $downloadPath -DestinationPath $endLocation -Force
        Write-Host "`r[✓] $($langmap.4)... $($langmap.2)"
    } else {
        Copy-Item -Path "$downloadPath" -Destination "$endLocation"
    }
    

    #clean up TEMP
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] $($langmap.5)..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.6)..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    Remove-Item "$downloadPath" -Force
    Write-Host "`r[✓] $($langmap.6)... $($langmap.2)"

    #format version number
    $versionNumber = $versionCode.replace('v','')

    $versionNumber
}

$shareoptionequivalencemap = @{
    '1' = 'partageseliasgerard'
    '2' = 'partagesmarianneautres'
    '3' = 'partageseliasjames'
    '4' = 'partagesmarianneelias'
    '5' = 'partagesgerardautres'
    '6' = 'partagesmariannegerard'
    '7' = 'partagesgerardjames'
    '8' = 'partagesalanjames'
    '9' = 'partagesjuliettemarianne'
    '10' = 'partagesjuliettemarianne'
    '11' = 'partagesjulietteautres'
    '12' = 'partagesalanautres'
    '13' = 'partagesjulietteelias'
    '14' = 'partagesalanelias'
    '15' = 'partagesjuliettegerard'
    '16' = 'partagesalangerard'
    '17' = 'partagesjuliettejames'
    '18' = 'partagesjamesautres'
    '19' = 'partageseliasautres'
    '20' = 'partagesmariannealan'
}

$sharenameequivalencemap = @{
    'partageseliasgerard' = "$shareORpartage Elias-Gérard"
    'partagesmarianneautres' = "$shareORpartage Marianne-Autres"
}

$productEquivalenceMap = @{
    '1' = 'SFTPmount'
    '2' = 'VPN'
    '3' = 'SBackup'
    '4' = 'SDownload'
}

# Write-Output " ____                             ____             _             "
# Write-Output "/ ___|  ___ _ ____   _____ _ __  |  _ \  ___ _ __ | | ___  _   _ "
# Write-Output "\___ \ / _ \ '__\ \ / / _ \ '__| | | | |/ _ \ '_ \| |/ _ \| | | |"
# Write-Output " ___) |  __/ |   \ V /  __/ |    | |_| |  __/ |_) | | (_) | |_| |"
# Write-Output "|____/ \___|_|    \_/ \___|_|    |____/ \___| .__/|_|\___/ \__, |"
# Write-Output "                                            |_|            |___/ "


Write-Output " "
Write-Output "================================================================="
Write-Output "Welcome to ServerDeploy ! This tool will guide you into configuring your access to the GrigWood server."
Write-Output "This device can serve many purposes : "
Write-Output "  - storing data, including some automated backups"
Write-Output "  - encrypting all your Internet connection "
Write-Output "  - completely deleting ads from the pages you visit"
Write-Output "  - Download big files off the Internet without heating up your computer"
Write-Output "And many more..."
Start-Sleep 15
Write-Output " "
Write-Output "So let's start !"
Write-Output " "
Write-Output "-----------------------------------------------------------------"
Write-Output "Here are all the different components of this system :"
Write-Output "    1. SFTPmount : Access the files on the server as if they were on a hard drive connected to your computer"
Write-Output "    2. VPN : Encrypt your traffic so hackers can't snoop, get rid of ads on the Internet, and (optional) hide you IP adress"
Write-Output "    3. SBackup : Backup folders you select to your dedicated space on the server ⚠️  NOT SUPPORTED YET"
Write-Output "    4. SDownload : Download large files off the Internet ⚠️  NOT SUPPORTED YET"
$serverInstallOptionsList = Read-Host "Please type in the numbers of the subproducts separated by spaces (and in order, please) "
$serverInstallOptionsArray = $serverInstallOptionsList.Split(" ")

if (($serverInstallOptionsArray.Contains("3")) -and (-not ($serverInstallOptionsArray.Contains("1")))){
    Write-Output " "
    Write-Output "[✗] You have selected option 3 (SBackup), but it requires option 1 (SFTPmount)."
    if ((Read-Host "Shall we add SFTPmount to list ? [y | n] ") -eq "y"){
        $serverInstallOptionsArray = $serverInstallOptionsArray + '1'
        Write-Output "[✓] Added SFTPmount to list !"
    } else {
        if ((Read-Host "Are you sure ? [y | n] ") -eq "y"){
            $time = 5
            do {
                Write-Host -NoNewline "`rExiting in $time seconds..."
                $time = $time - 1
                Start-Sleep 1
            } until ($time -eq 0)
            exit
        }
    }
}

foreach ($serverInstall_currentOption in $serverInstallOptionsArray){
    Write-Output " "
    Write-Output "-----------------------------------------------------------------"
    Write-Output "$($productEquivalenceMap["$serverInstall_currentOption"]) setup :"
    $currentFolder = "$binairiesDir\Kirkwood Soft\ServerDeploy\$($productEquivalenceMap["$serverInstall_currentOption"])"
    creatingLoading -createType "directory" -createpath "$currentFolder" -lang $lang -createname "$($productEquivalenceMap["$serverInstall_currentOption"])"
    if ($serverInstall_currentOption -eq "1"){
        creatingLoading -createType "directory" -createpath "$currentFolder"
    }
}




Write-Output "Installing main code :"
$timesofpoint = 0
do {
    Start-Sleep -Milliseconds 400
    Write-Host -NoNewline "`r[.] Creating file : mount.vbs..."
    Start-Sleep -Milliseconds 400
    Write-Host -NoNewline "`r[ ] Creating file : mount.vbs..."
    $timesofpoint = $timesofpoint + 1
} until ($timesofpoint -eq 2)
$fileexists = (Test-Path -Path "D:\programs\Server\mount.vbs" -PathType Leaf)
if ($fileexists -eq $false){
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value 'Set objFSO = Createobject("Scripting.FileSystemObject")'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value 'Set oFolder = objFSO.GetFolder("C:\programs\Server\submounts")'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value 'For Each oFile in oFolder.Files'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value '    Dim WinScriptHost'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value '    Set WinScriptHost = CreateObject("WScript.Shell")'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value '    WinScriptHost.Run Chr(34) & oFolder & Chr(92) & oFile.Name & Chr(34), 0'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value '    Set WinScriptHost = Nothing'
    Add-Content -Path "D:\programs\Server\mount.vbs" -Value 'Next'
    Write-Host "`r[✓] Creating file : mount.vbs... Done !"
}else{
    Write-Host "`r[✗] Creating file : mount.vbs... Failed (file already exists)"
}

Write-Output " "

Write-Output "-----------------------------------------------------------------"
Write-Output "Shared folders selection :"
Write-Output "1. Partages Elias-Gérard                     11. Partages Juliette-Autres"
Write-Output "2. Partages Marianne-Autres                  12. Partages Alan-Autres"
Write-Output "3. Partages Elias-James                      13. Partages Juliette-Elias"
Write-Output "4. Partages Marianne-Elias                   14. Partages Alan-Elias"
Write-Output "5. Partages Gérard-Autres                    15. Partages Juliette-Gérard"
Write-Output "6. Partages Marianne-Gérard                  16. Partages Alan-Gérard"
Write-Output "7. Partages Gérard-James                     17. Partages Juliette-James"
Write-Output "8. Partages Alan-James                       18. Partages James-Autres"
Write-Output "9. Partages Juliette-Marianne                19. Partages Elias-Autres"
Write-Output "10. Partages Juliette-Alan                   20. Partages Marianne-Alan"
Write-Output " "

Read-Host $shareoptions = "Please type in the numbers of the options, separarted by spaces "

$shareoptionsarray = $shareoptions.split(" ")
$outshareoptionsarray = $shareoptionsarray | ForEach-Object {
    $selectedshareoption = $_;
    Write-Output $shareoptionequivalencemap[$selectedshareoption]
}

foreach ($i in $outshareoptionsarray) {
    Add-Content -Path "D:\programs\Server\submounts\$i" -Value "rclone mount sftp-nas:/$i "D:\Partages\$shareORpartage Elias-Gérard""
}
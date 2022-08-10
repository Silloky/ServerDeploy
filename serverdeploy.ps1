param (
    [switch]$NewInstallation = $false,
    [switch]$ReConfigure = $false
)


if (Test-Path -Path "$env:programfiles\Kirkwood Soft"){
    $binairiesDir = "$env:programfiles\Kirkwood Soft"
    $userDataDir = "$env:appdata\Kirkwood Soft"
} elseif (Test-Path -Path "$env:appdata\Kirkwood Soft\binairies") {
    $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
    $userdataDir = "$env:appdata\Kirkwood Soft\data"
}

$tempDir = "$env:temp"

if ((Get-Content -Path "$binairiesDir\LANGUAGE.txt") -eq "FR"){
    $langmap = $frlangmap
    $lang = "FR"
} elseif ((Get-Content -Path "$binairiesDir\LANGUAGE.txt") -eq "EN"){
    $langmap = $enlangmap
    $lang = "EN"
}

function Decrypt {
    Param(
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeLine=$true)] [Alias("String")] [String]$EncryptedString,
    
        [Parameter(Mandatory=$True, Position=1)] [Alias("Key")] [string] $EncryptionKey
    )

    $enc = [system.Text.Encoding]::UTF8
    $Key = $enc.GetBytes($EncryptionKey)
    Try{
        $SecureString = ConvertTo-SecureString -String $EncryptedString -Key $Key
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        [string]$String = [Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        Return $String
    }
    Catch{Throw $_}
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
            if ($createType -eq "file"){$ItemType = "File"}
            if ($createType -eq "directory"){$ItemType = "Directory"}
            $null = New-Item -Path "$createpath" -Value "$foldername" -ItemType $ItemType
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
        [Parameter(Mandatory = $false, Position = 0)] [string] $endLocation,
        [Parameter(Mandatory = $true, Position = 0)] [string] $file,
        [Parameter(Mandatory = $true, Position = 0)] [string] $lang,
        [Parameter(Mandatory = $true, Position = 0)] [string] $token,
        [Parameter(Mandatory = $true, Position = 0)] [string] $key

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
    $credentials = Decrypt -EncryptedString "$token" -EncryptionKey $Key
    $repo = "silloky/$repo"
    $headers = @{
        'Authorization' = "token $credentials"
        'Accept' = 'application/vnd.github+json'
    }
    $credentials = $null
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
    $credentials = Decrypt -EncryptedString "$token" -EncryptionKey $Key
    $headers = @{
        'Authorization' = "token $credentials"
        'Accept' = 'application/octet-stream'
    }
    $credentials = $null
    $downloadPath = $([System.IO.Path]::GetTempPath()) + "$file"
    $download = "https://" + $credentials + ":@api.github.com/repos/$repo/releases/assets/$id"
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -Uri "$download" -Headers $headers -OutFile $downloadPath
    Write-Host "`r[✓] $($langmap.3)... $($langmap.2) ($versionCode)"
    $headers = $null

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

function applyWireGuardConfig{
    param (
        [Parameter(Mandatory = $true, Position = 0)] [string] $configPath,
        [Parameter(Mandatory = $true, Position = 0)] [string] $interface        
    )
    $timesofpoint = 0
    do {
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[.] Applying WireGuard config to interface $interface..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] Applying WireGuard config to interface $interface..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    wg.exe setconf $interface $configPath
    Write-Host "`r[✓] Applying WireGuard config... Done !"
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
    '10' = 'partagesjuliettealan'
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
    'partageseliasgerard' = "Elias-Gérard"
    'partagesmarianneautres' = "Marianne-Autres"
    'partageseliasjames' = "Elias-James"
    'paratgesmarianneelias' = "Marianne-Elias"
    'partagesgerardautres' = "Gérard-Autres"
    'partagesmariannegerard' = "Marianne-Gérard"
    'partagesgerardjames' = "Gérard-James"
    'paratgesalanjames' = "Alan-James"
    'partagesjuliettemarianne' = "Juliette-Marianne"
    'partagesjuliettealan' = "Juliette-Marianne"
    'partagesjulietteautres' = "Juliette-Autres"
    'partagesalanautres' = "Alan-Others"
    'partagesjulietteelias' = "Juliette-Elias"
    'partagesalanelias' = "Alan-Elias"
    'partagesjuliettegerard' = "Juliette-Gérard"
    'partagesalangerard' = "Alan-Gérard"
    'partagesjuliettejames' = "Juliette-James"
    'partagesjamesautres' = "James-Others"
    'partageseliasautres' = "Elias-Others"
    'paratgesmariannealan' = "Marianne-Alan"
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
Start-Sleep 5
Write-Output " "
Write-Output "So let's start !"
Write-Output " "
Write-Output "-----------------------------------------------------------------"


if ($NewInstallation -eq $true){
    Write-Output "Here are all the different components of this system :"
    Write-Output "    1. SFTPmount : Access the files on the server as if they were on a hard drive connected to your computer"
    Write-Output "    2. VPN : Encrypt your traffic so hackers can't snoop, get rid of ads on the Internet, and (optional) hide your IP adress"
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
        Write-Output "      - $($productEquivalenceMap["$serverInstall_currentOption"]) setup :"
        $currentFolder = "$binairiesDir\ServerDeploy\$($productEquivalenceMap["$serverInstall_currentOption"])"
        creatingLoading -createType "directory" -createpath "$currentFolder" -lang $lang -createname "$($productEquivalenceMap["$serverInstall_currentOption"])"
        if ($serverInstall_currentOption -eq "1"){
            $token = "76492d1116743f0423413b16050a5345MgB8AFgAUQBqAE8AcgA0AEgAaQBpAEgAQQBjAHYAagBTAHIARgBNADAALwA2AFEAPQA9AHwAZQBjADUAYQA2AGIAYwA2AGUANwBjADEANQA5ADAAOAA1ADgAOABlADEAMAAxADUAOQA2AGEAZQA1AGQANQAwADcANABmAGYAZgA3ADQAZAA4AGIAMQAyADgAYwBlADYAZgA1ADMAYwBhADMAMgAyADAANgA2ADIANAA4AGQAMwA0ADcAZgAyAGQAYwBlADgAYQA3ADIAZQA0AGEAOQAxADYAMAA1ADQAMgA2AGMAZQBhAGYANwA5ADIANgBhADQAOQA0ADMAMgBhAGQANQA1AGUAMgBjADgAYQA1ADUANABmADkAYgA4ADIAMAAxAGYANABhADIAZgAyAGEAOQA4ADcAMwAzADUAZAA1ADkAYwAyADQAOABlADUAOABlAGIANwAwADAAZABlADcAYgBkADMAYwA4ADMAZgBjAGUAMgBjADQAMABkADIAYwA3ADUAMwBhADgAOQAyADIAMgAwAGQAYwA1AGEAMgAyADkAZQAzADAAOQBlADYAMABkADEA"
            $key = Read-Host "Please type in the security key given to you during the training "
            dlGitHub -repo "ServerDeploy" -file "mount.vbs" -lang $lang -endLocation "$currentFolder" -token "$token" -key "$key"
            creatingLoading -createType "directory" -createpath "$currentFolder\submounts" -lang $lang -createname "submounts"
            $dlRclone = Start-Job -ScriptBlock {
                param (
                    $tempDir
                )
                curl.exe -o "$tempDir\rclone.zip" https://downloads.rclone.org/rclone-current-windows-amd64.zip
                } -ArgumentList $tempDir
            do {
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[.] Downloading rclone..."
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[ ] Downloading rclone..."
                $timesofpoint = $timesofpoint + 1
            } until ($dlRclone.State -eq "Completed")
            Expand-Archive -Path "$tempDir\rclone.zip" -DestinationPath "$tempDir\rclone" -Force
            $rcloneExe = Get-ChildItem -Path "$tempDir\rclone" -Filter "rclone.exe" -Recurse | ForEach-Object{$_.FullName}
            Copy-Item -Path "$rcloneExe" -Destination "$binairiesDir\ServerDeploy\SFTPmount\rclone.exe" -Force
            Remove-Item -Path "$tempDir\rclone\*" -Recurse -Force
            Remove-Item -Path "$tempDir\rclone.zip"
            Write-Host "`r[✓] Downloading rclone... Done !"
            creatingLoading -createType "directory" -createpath "$env:appdata\rclone" -createname "rclone" -lang "$lang"
            $username = Read-Host "Please enter your server username "
            $password = Read-Host "Please enter your server password "
            creatingLoading -createType "file" -createpath "$env:appdata\rclone\rclone.conf" -createname "rclone.conf" -lang "$lang"
            $escapedBinairiesDir = $binairiesDir.Replace(" ","` ")
            Invoke-Expression -Command "$escapedBinairiesDir\ServerDeploy\SFTPmount\rclone.exe config create test sftp host `"grigwood.ml`" port `"50007`" user `"$username`""
            Invoke-Expression -Command "$escapedBinairiesDir\ServerDeploy\SFTPmount\rclone.exe config password sftp-nas pass `"$password`""
            Write-Output " "
            Write-Output "Folders selection :"
            Write-Output "  1. Shares"
            Write-Output "  2. General Storage"
            if ($person -ne "elias"){
                Write-Output "  3. Backups"
            }
            $NASfoldersOptions_list = Read-Host "Please type the numbers of the options you wish separated by spaces "
            $NASfoldersOptions_array = $NASfoldersOptions_list.Split(" ")
            foreach ($NASfoldersOptions_current in $NASfoldersOptions_array){
                if ($NASfoldersOptions_current -eq '1'){
                    $shareLocation = "$env:userprofile\Shares"
                    Write-Output "The default place for the Shares folder is $env:userprofile."
                    if ((Read-Host "Do you wish to change that ? [y | n]") -eq "y"){
                        $shareLocation = Read-Host "Please type in the place where you want the Shares folder to be located "
                    }
                    creatingLoading -createType "directory" -createpath "$shareLocation" -lang "$lang" -createname "Shares"
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

                    $shareoptions = Read-Host "Please type in the numbers of the options, separated by spaces "

                    $shareoptionsarray = $shareoptions.split(" ")
                    $outshareoptionsarray = $shareoptionsarray | ForEach-Object {
                        $selectedshareoption = $_;
                        Write-Output $shareoptionequivalencemap[$selectedshareoption]
                    }

                    foreach ($outshareoptions_current in $outshareoptionsarray){
                        creatingLoading -createType "file" -createpath "$currentFolder\submounts\$outshareoptions_current.bat" -createname "$outshareoptions_current.bat" -lang "$lang"
                        Add-Content -Path "$currentFolder\submounts\$outshareoptions_current.bat" -Value "rclone mount sftp-nas:/$outshareoptions_current `"$shareLocation\Share $($sharenameequivalencemap[$outshareoptions_current])`""
                    }
                }
                if ($NASfoldersOptions_current -eq '2'){
                    if ((Read-Host "Do you wish to access General Storage as a constantly plugged-in USB Drive (recommended) or as a simple folder ? [d | f] :") -eq "d") {
                        $generalAsDrive = $true
                        $generalLocation = "S:"
                        if ((Test-Path -Path "$generalLocation") -eq $true) {
                            $generalLocation = Get-ChildItem function:[h-z]: -n | Where-Object{ !(test-path $_) } | Select-Object -First 1
                        }
                        Write-Output "General Storage will be mounted as $generalLocation with the label `"General Storage`""
                    } else {
                        $generalAsDrive = $false
                        $generalLocation = "$env:userprofile\General Storage"
                        Write-Output "The default place for the General Storage folder is $env:userprofile."
                        if ((Read-Host "Do you wish to change that ? [y | n]") -eq "y") {
                            $generalLocation = Read-Host "Please type in the place where you want the General Storage folder to be located "
                        }
                    }
                    creatingLoading -createType "file" -createpath "$currentFolder\submounts\mountgeneral$username.bat" -createname "mountgeneral$username.bat" -lang "$lang"
                    Write-Output "rclone mount sftp-nas:/general$username `"$generalLocation`"" > "$currentFolder\submounts\mountgeneral$username.bat"
                }
                if ($NASfoldersOptions_current -eq "3"){
                    if ((Read-Host "Do you wish to access Backups as a constantly plugged-in USB Drive (recommended) or as a simple folder ? [d | f] :") -eq "d"){
                        $backupsAsDrive = $true
                        $generalLocation = "B:"
                        if ((Test-Path -Path "$generalLocation") -eq $false) {
                            $generalLocation = Get-ChildItem function:[i-z]: -n | Where-Object{ !(test-path $_) } | Select-Object -First 1
                        }
                        Write-Output "Backups will be mounted as $generalLocation with the label "Backups""
                    } else {
                        $backupsAsDrive = $false
                        $backupsLocation = "$env:userprofile\Backups"
                        Write-Output "The default place for the General Storage folder is $env:userprofile."
                        if ((Read-Host "Do you wish to change that ? [y | n]") -eq "y"){
                            $generalLocation = Read-Host "Please type in the place where you want the Shares folder to be located "
                        }
                    }
                    creatingLoading -createType "file" -createpath "$currentFolder\submounts\mountbackups$username.bat" -createname "mountbackups$username.bat" -lang "$lang"
                    Add-Content -Path "$currentFolder\submounts\mountbackups$username.bat" -Value "rclone mount sftp-nas:/backups$username "$generalLocation""
                }
            }
            $autoMount = Read-Host "Do you want the folders selected above to be automatically mounted when you start your computer (recommended) [y | n]"
            if (($autoMount -eq 'y') -or ($autoMount -eq 'o')){
                Write-Output " "
                Write-Output "-----------------------------------------------------------------------"
                Write-Output "Scheduling mounting task :"
                $timesofpoint = 0
                do {
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[.] Configuring action..."
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[ ] Configuring action..."
                    $timesofpoint = $timesofpoint + 1
                } until ($timesofpoint -eq 2)
                $scheduledAction = New-ScheduledTaskAction -Execute "$currentFolder\mount.vbs" -Argument "`"$currentFolder\submounts`""
                $scheduledTrigger = New-ScheduledTaskTrigger -AtStartup
                $scheduledSettings = New-ScheduledTaskSettingsSet -RunOnlyIfNetworkAvailable
                $scheduledTask = New-ScheduledTask -Action $scheduledAction -Trigger $scheduledTrigger -Settings $scheduledSettings
                Register-ScheduledTask -TaskName 'ServerDeploy Automatic Mounter' -InputObject $scheduledTask -User "NT AUTHORITY\LOCALSERVICE"
            } elseif ($autoMount -eq 'n'){
                Write-Output "Alright, a shortcut will be available to start the mounting software manually."
            }
        }
        if ($serverInstall_currentOption -eq "2"){
            Write-Output " "
            Write-Output "-----------------------------------------------------------------"
            Write-Output "      - $($productEquivalenceMap["$serverInstall_currentOption"]) setup :"
            Write-Output "This option uses some very good software called WireGuard."
            $dlWG = Start-Job -ScriptBlock {
                param (
                    $tempDir
                )
                curl.exe -o "$tempDir\wireguard-installer.exe" https://download.wireguard.com/windows-client/wireguard-installer.exe
                } -ArgumentList $tempDir
            do {
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[.] Downloading WireGuard installer..."
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[ ] Downloading WireGuard installer..."
                $timesofpoint = $timesofpoint + 1
            } until ($dlWG.State -eq "Completed")
            Write-Host "`r[✓] Downloading WireGuard installer..."
            Write-Output "The installer is going to ask you if you it to make modifications to your PC. Please answer "Yes" to this."
            Write-Output "Once some big white window pops up, you can close it and come back here."
            Start-Sleep 3
            Start-Process "$tempDir\wireguard-installer.exe"
            Start-Sleep 10
            Write-Output "Press any key to continue :"
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            Remove-Item "$tempDir\wireguard-installer.exe"
            $username = Read-Host "Please type your server username "
            $Key = Read-Host "Please type in the security key given to you during the training "
            $timesofpoint = 0
            do {
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[.] Creating WireGuard config..."
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[ ] Creating WireGuard config..."
                $timesofpoint = $timesofpoint + 1
            } until ($timesofpoint -eq 2)
            $ipEquivalenceVPN = @{
                'elias' = "10.100.0.2/32, fd08:4711::2/128"
                'marianne' = "10.100.0.3/32, fd08:4711::3/128"
                'juliette' = "10.100.0.4/32, fd08:4711::4/128"
                'alan' = "10.100.0.5/32, fd08:4711::5/128"
                'gerard' = "10.100.0.6/32, fd08:4711::6/128"
                'james' = "10.100.0.7/32, fd08:4711::7/128"
            }
            $encryptedPublicKeys = @{
                'elias' = "76492d1116743f0423413b16050a5345MgB8AG8AZgBjAEEAegB2ACsAeABuAGYANQA2AFQAQwAyAEEAKwBvAEgALwB6AHcAPQA9AHwANwA0ADYAMwBmADQAMAAzAGMANgAxADEAZgBlADkAMAA4AGMAYgA5AGEAOAAyADkAOQAzADcAZgAzADgAZQAyADEANwAwAGYAZQA1ADMAMgBlADcAOQA4AGEANAA4AGIAMwBmAGYAMQBhADAAZQBhAGUAZQA0ADYANAAyAGUAOAA4AGUAYQA5ADgAZgBkADUAMgA3ADAAZQAzAGEAYgA1ADgANgBhADEANAAzAGYAYgBlADAAOQA4ADQAMgA1ADIAYgA0AGIAMABjAGMAMgAzADcAMAA0AGQAOAAzADEAOABlADMAOABhADUANABhADMAZABhAGMAMwBjAGMAZQA1AGEAOAAxADIAZAAwAGMAOQA5ADYAZAAwAGIAOQBhADEANgAzAGEAYQAyADQAMQAzAGUAMgBiADEANQAwADEAZABiADAANABlADcAMQA5AGUAYQAxADkAMABlADIAOQBjAGYANQA4ADQANAA1AGEAMwBmADUAYQBlADQAMgBiAGMA"
                'marianne' = "76492d1116743f0423413b16050a5345MgB8AHYAOQBMAGMAUwBiAEoAWgBoAEYATwAyAEoAYwBRAEsALwBiAGYAbwAzAGcAPQA9AHwANwAxADIAMwAzADYAZQA3ADMAMgBkAGEANgAwAGEANQBiADAAZABiAGUAYwA3ADAAMgBjADcAZgAwADYAZABjAGQAOAA4ADAAMgAzADgAZQBlADAAYQA3AGEAYQAwAGQAYwBlADMAZQBkAGQAZQA2ADgANgA3AGEANQA2ADQAMAA3ADcANgA4ADAANQA0ADYANAA0ADMAYgBmAGYANwA2ADMANAA3ADMAZgAzAGQANgBlADIAZgBjAGIAZgBlADkAYwA2ADQAMwAxADYAMwA1ADAAYgA1AGQAOQAwADcAYQBkADIANgA5ADUAZAAxAGMAZgA2AGMAMgA3AGYAMQA4ADUAYQA3ADgAOQAwADIANABkAGQAMABhADYAYwBlADAAMwAyADYAMgAzAGIANgAyADgANgAxAGYAYQAwADQAMAA3ADMANQBkADcAMgA5ADAAOQAxAGIAYQBjADAAMABkADEANgA3AGMAMQA1ADYANwA4AGMAOAA2ADgANgA4AGEA"
                'juliette' = "76492d1116743f0423413b16050a5345MgB8ADYATwB3ADYARwBUAGEAcwBuAEEAdABhAEkATABvAFQALwBrAFAASwB3AGcAPQA9AHwANwBkADYAMQBhADEAMwA0ADQAMAA0AGYANQA0AGYAOQA1AGQANwA4AGQAYwBhADQANgA2ADMAMgBhADMAOQBjADYANQAxADAANAAzADMAMQA0ADAANwAzAGEAOQA2ADEAZAA4AGQAZgA2ADcAZgA1AGUAOAA1AGEAMABlAGEAOABkADUAYwA3ADYAMwAxADMAOQAyADAANAAyAGYAZABlADcANQBhADEANwBmADQAZABjADQAMgA2ADgAMgAzADQAYgAzAGUANQBiAGEAMgA5ADkAYwAwADIAMQAwADUAMQA1AGIAZgAwAGQAOQA4ADgAMQA0ADAAZABkADkAZABhAGUAZQA1AGIANgBjADAANwA4ADcAZAA2ADAAMAAxAGUANgBkADUAYQBlAGMANQBkADkAMAA4AGYAZgA0AGUAZQBkAGUANQA1ADQAYwAxADIAMwBkADgAZQA3AGYAYwA1ADAAOABhADIAOABjAGUAOQA2AGUAZgA0ADMANAAzADEA"
                'alan' = "76492d1116743f0423413b16050a5345MgB8AFkAQQBCAG4AcgBaAFEAQQB2AG0ARgA3AGMAYgByAGIAZAArADMAYQBiAGcAPQA9AHwAYgA5ADYANAA4ADgANgA0AGYAMAA0ADEANAA0AGEAZQA4AGYAMgA2ADgAMgA0AGYAMgAzADgANwAzADAAOABhAGEAMQA1ADQAYgBmADEAMAA1AGMANgBkADMAMgBiADcAMAA1ADcAYQA4ADMAMQBiADcANAA2ADAAZQA1ADYAZQA4AGYAMwA1ADEAMAAwADgAOABiADgAYwBlAGMAOAA3AGIAZABmADUAOAA4AGEAOQAxAGQAOQAyAGYAOABjAGIAZQAwADAAMwBlADgANgAwADUAMwAxAGQAYwBhADIAMABhAGUANABhADUANQA2AGUAOAA1AGIANAAwADcAZABlADkAMgBiADgAMwBjAGQAZgBkADgAMAA5ADEAYwBiAGQAZgA5ADEAMQA3AGMANwA5AGYAYgAxAGQAMQAzADIANgBkAGQAOQA5ADgANQA4ADEAYQAzADcAZABlADAAZAA4ADAAZgA1AGMAZgA0ADcAMQA2ADcAMwAwADEANQAzAGYA"
                'gerard' = "76492d1116743f0423413b16050a5345MgB8ADgAcwBHAHgAOABnAC8ARgBvAEUAbQBxADIAaQBUAGMAMgBpAGkAZgBrAHcAPQA9AHwAOQA1ADgAYQAwADQANgAzADEAMQAxAGMANwAwAGYAZAA1AGQAZgBhADUANgA5AGIAYgBlAGYAOQA0ADgAOAA5ADMAZQBjADIAMgA4ADQAMAA2ADcAMgA5AGQAZQBmADEANgBhADcAMQBiAGUAZgA2AGYANQBkADEAOQAzADMAMAA4ADMAMgA1ADgAZgA1ADYAMwA5ADIAMgBiADIAZQA3AGQAZAA1ADkAMgBhAGIAMQA2ADAAMAA4AGQANAAxADQAZgBhADQAYgBmADYAZgAwADcANQBkAGUAYgA1ADUANQBiAGIAMwA0AGEANgA1ADkAZQAyADYAZAA5ADIAMgBkADgANgBmADkANQAzADcANABhADAAYgBkAGEAYwA5ADYAMQA4AGUAMgBmADYANwAwAGEAZQA5AGMANAA0AGUANgAyADUAMABlAGMAZgA1ADkAYwBhADMAMQAzADAAOQA1AGUANQA0ADMAMgA2ADEAOABmADcAMwBmADMAOAA0AGMA"
                'james' = "null"
            }
            $encryptedPrivateKeys = @{
                'elias' = "76492d1116743f0423413b16050a5345MgB8AHMAbQAvAE8AawBiAHYAWQBTAHUAVgBDAEgAYwBuAEcANwBTAHYAcgByAEEAPQA9AHwAZAA2ADEANgA0ADcAYQA1AGEAYQAzADkANwA0ADkAYwA3AGEAMQA0ADEAYwAxADgAMgAzADkAZQBhADkANAA5ADAAMAA0ADgANQBmADUAYgBmADEAZQA0ADYANABiADgAYwA4AGMAOQA1ADUAZQA0AGUAOABkADYANgBjADMAYwA5AGUAZABiAGQAYQA0ADkAMgA1ADUAYwAxADcAMwA0ADQAOAA4ADUAYgAzAGYANgA1AGUANgA5ADMAMQAzADcAZQAwADAAYgBiADIANgA4ADIAZAA2ADQANAA5ADUANgBmADEAMQA3AGMAMABkAGYAMwAzADcAMABmADQAZgBmADgAZQBmAGQANQAyADUAMABjADIAMAA3ADIANgBkAGMANgA3AGIAYwBkADcAYQBmAGIAOQA1ADYAYgA3AGUAOQBmADIAYwBhAGEANABjADAAMQAzAGMAZAA3ADEAMAA0ADYAOQBmAGUAMwA3ADcAMwBmAGIAMwA2AGEAMAA0AGIA"
                'marianne' = "76492d1116743f0423413b16050a5345MgB8AGwAUQBsAGkANABwAGgATwA1AGQAWgB3AEYAWAAzAFYAdgB3AC8AWABYAFEAPQA9AHwAMAAwAGEANABjAGEAYgA4AGEAMgBmAGUAOABkAGQAZABmAGUAOABkADMAMgBiADIAZgA5AGIAOAA1ADAANwA0AGUANABmADQAYQBiADMAMwA4ADgAOQA3ADcAZQBkADQANwBkADEANQA1AGIAMQBmADUAOAA4AGEAMwA4ADcAZABjADEAZAA0ADAANQAyADgAOQA5ADEANQA4ADkAMgA2AGMANgBiAGUAYwAwAGMAZAA4ADIANQBhAGEANQA2ADAAYgA2AGEAOABmADcAOQA1ADYANwBmADcAZAAwADgAOABiADAAOQBiADMAYQA0AGYAOQA4ADgAZgAwADIANABhADUAYgAxAGUAZABlADIAOAAwAGIANgA3AGIAMwAxAGQAMgBlADAANABlADYAOQAxADcAMQAyADMAMAA0AGEAZQBmADgAYgA1ADMAOQBhADcAMwA2ADQANgAxADgAMgAxADEAMgAyAGYAYwA2AGYAYgAwAGQANQA4ADAAZABlADAA"
                'juliette' = "76492d1116743f0423413b16050a5345MgB8AHEAUwBaAFQAcAAyAFgAbgAwAHYAcgB0AEcAeQBJAFYAMgBqAHMAQQBCAGcAPQA9AHwAYQA5ADAANgAwADkAOAAyADEAMQA5ADAAOAA2ADYANgAxADMAOAAyAGQAMgBmADMAMwBmADUAZQBiADcAOAA4ADEANABiADMAMAA1AGEAMQAxAGQANwAwADIAZQA2AGEAOABkADMAMABmADgAZQBhADYANgAyADQAMAAxAGUAZAAzADgAMwAzADEAZABjADIANQAwAGEAZAAyAGMAYQAwADIAYQA2ADkAYgA5ADMANQAyADUAMQA5AGMAMgAyADcANgBkADcAZAA3AGYANwAyAGYAYwA4ADEAOAAxAGUAZQBhAGIANQA1AGQANwA4ADAAMgA3ADgANgA2ADUAMwA5ADAANgAwADYAMwBmADIAMwA3ADgAYwAzADkAZAA3ADUAYQBkADkANQA0ADgANQBmAGUAYwAwADQAZQAxADIAMgBmADEANQBmAGMAOAA4ADkAYgA3ADcAYwBlADAANQA2ADkAMABhADQANgA1ADcAZQBmADYAZgBlADcANAA5ADUA"
                'alan' = "76492d1116743f0423413b16050a5345MgB8AEMAZAA2ADEANgBlAFoATAB3AHkALwAxAFIAegBRAE4AZQBnAE4AZgBsAHcAPQA9AHwAZABhAGYAZQBjAGEAOAA0ADMAYQBhADcAMwA1ADcANgAyADYANgA0ADIAZQA0AGQANwBiADgAMwAwADYAOAAyADkANwBhADUAZQA4ADkANwAyAGEAMAAxAGMANwBkAGIAOABlAGIAZgBjADAANQA4ADEANwAxAGUAYwA0ADQAMwAxAGYAOAA2AGEAOABkAGYAMABlADAANgBlAGIAYgBlADUANAA3AGUANQBkAGYAMQAxADEANAAwAGQANAA4ADAAMwA3ADEAYgAyADAAMgA1ADUANABlAGEAMQAzADgANABkADMANgA0AGQAYgBhAGQAMAAwADEANwA5AGMAYgBmADMAZQAzADQAMAA3AGQAMAA2ADAAOAAyADEAZgA5ADAAYgA4ADcAMgA5AGYAOAA3ADIAYwBiADcANwA3ADYAYQAyAGUAMwAxADgAYgBlADkAMgBmADcAMAA1AGQAYgBiAGQAYwBiADUAMwA3ADQANQA1ADEAZABkADUAOQBmADcA"
                'gerard' = "76492d1116743f0423413b16050a5345MgB8AEcAOAAxAGUAawBYAEMARgBsAFIAQwA4AE0AUgBWAHIAeQBWAEIAbQBFAFEAPQA9AHwAMwA4ADcAYQA3ADgANwAwADcAZgAwADgAMgBiADgANABjADUAZQBjADkAYQBjADMAMQBkAGUAMgA0AGMAYQA2ADQAMQAzAGUANwAyADcAMABiADYANgA2ADIAOAAwAGYANwA2ADQAYQA3ADUANQAxADQAZgBjADAAMgAzAGEAOABkADYAMAA1ADgAYQBlADkANwA3AGIAMgBiADQAYQAwADAANgBkAGUAYwA5AGMAOQAyADQAZABhADkAOQA1AGQAYgBjAGEAMgA4ADMAMwBkAGEAMAAxADEANQBiAGMANQAxADEANgAwADcAMABkADYAZAAwAGMANQBjAGEAMwA1AGMAMgBlADgAZgBjAGQANQA4AGYAMgA3AGIANQA2ADMAZgBmADYAZQAzAGYAZQAyADUAYgA4ADQAYgBkADIANgBmADIAMABhAGYANwAyAGYAMgA1ADUANgBkADQANwBkADgAMwA0ADkAOQA2ADAAOABjAGEANwAxADYAYwA3ADMA"
                'james' = "76492d1116743f0423413b16050a5345MgB8AG0AeABkAHoAcQBKAEEAaQBvAG4AVwBmAEMATAB6AGkANwBjAFgAUwBJAGcAPQA9AHwAOQBhADEAYQBkADYAZAA0AGYANAA0ADEAMAA1ADIAMABlADEAMQA1AGIAOABhADgAZAA2AGEANABjAGQAYwA3AGIANgBhAGQAZgBjADAANQBkADEAYwBhADQAZAAyADgAYgAwAGYAMwBjADQANwAwADUAOQAxADMANgA2ADMAYwA4AGIANAAzAGYANgBiAGEAMwAzADUANgA3AGMAMABhAGUAOAAwADgAZgA5AGYAMQA5AGQAMgA1ADUAMwA4ADMANQBhAGUAZQAwADgANwBiAGIAMQA3ADEAMAA1ADAANgAzAGYAZQA4ADEANwBmAGIANgBlADkAMAA3ADcAZQBkAGUAMgAwADIANwAxAGMAMAA4ADMAOQA2ADYANgA2ADgAMAAwADcANAA4ADEAZAAzADIANABhAGQANgBiADMAZAAzADYANwAwADkANgA0ADQANwBmADMANwAwAGUAMAA4AGMAOAAxADcAZQAwADAAMgA3ADkAZQAyADMAMQA0ADcA"
            }
            $encryptedPreSharedKeys = @{
                'elias' = "76492d1116743f0423413b16050a5345MgB8AGMAUwBaAFcAegBwAGIAYQBtAGoAVgBJADgASgBSADgANgAxAGoAOQBoAGcAPQA9AHwAZABmADUANgBmADIAZgA5ADAANAA1ADUAZQBkADgAMQAxADkAYwBkADYAZQAwADIAMgBlADkAMQBkADYAYgBmADMAZAA0AGIAMgA2ADUAZgAwADEANgA1AGUAMQA3ADYAZAAyADUANwAxADgAOQAxADkAYQBhADYAOAA3AGMAOQBhAGEAYwBkAGUANwA2ADIAMAA4ADQAMwA4ADAAZgBiAGYANgBlAGIAMwBhAGUAOQBlADMAMgBmAGEANwA1ADAAOQAzAGQAYQAyADQAMwBhADQAYQAzADMAMgA2AGUANABmADcAZQA2AGYAMwBhAGMANAAxAGEAZAA3ADAAZAA3AGYAOQBmADcANgBjAGUAZgA4ADEAOQAzADMAYgBmADQAZQA3ADgAMAA0ADEANwBmAGYAZAA4ADgAZgAxADkANwAxAGYANAA0AGQANgA2ADMANAA4AGMAZAA1ADMAZQA4ADcANQAwAGUAZABlADYAOAAyADMANwBmADgAMwBkADIA"
                'marianne' = "76492d1116743f0423413b16050a5345MgB8ADYASgBiAGMAZQA4AHUAcwB3AEUAZABVAHAAbgAyAFAAdwBxAFEAVgBSAEEAPQA9AHwAYQBiADQAZQAyADEAZQBjADUAOQBjADQAZQA1ADIAZABkAGIAOABjAGEAYQBkADAAOQAwADAAMgA0AGIANgBkAGQANgA0AGYAMABmAGUANABkADYAMQBkADgAOQA4ADgANAAyADUANwAxAGMAZQBmADYAMQBjAGQAZABiADMAYwAxADYANABiAGQAMQA3ADgAYwA2ADkANgAyADAAYwBlAGMAYwAzADQANwBlADUAMgBhAGQAZAA2AGUAZQA4ADMAYwA1AGUAZQBmADMANgAwADIAYQBjAGYAYQBjADYAZQA0ADUAZgAwAGYAYwA1AGQAZAA1AGUAMABhAGMAYgA5ADYANQAwAGYAZAAzAGUAOQA0AGYAZABjAGYAMAA1AGIAYgBiADMAYQAzADUAYgBiAGIAZABjAGQANgA5ADkANQA2ADQANgAwAGMANQBhADQANwA1AGYAOQAzAGQAZQBmAGEAMABkAGIAMwBlADIAZgA4AGQANwA2ADcANABiADEA"
                'juliette' = "76492d1116743f0423413b16050a5345MgB8AE4AQgBsADkAaABTAEwASAAyADMAMQA5AFEAcAB4AHYAbABCAGoAbgA0AGcAPQA9AHwAMwA5AGYANgA1AGYAMwBiADAAYwBiADMAMgBkAGMAMQA4ADYAZgA1AGQAYQA5ADYAMQBjADEAOQA4AGMAOQAzAGQAZgAxADgAZQBjADgAMgBhAGEAMwBjADYANwA5ADMAMAA5ADcAYQBmAGYAOAAzADMAYgA3AGYANwBlADcANgAwADQAMwAwADIAYQA2ADAAYwBlAGMAMgBkADQAZQBlADAAYQA4AGEAMAAzADUAZABkAGYAOQBjADEAZAA4ADMANwA3ADkAMQAyADQAOAA0AGIAZgBjADgAMAAxADIAMQBlAGMAOAAxADIAOQA5ADYAMQA3AGIAMABmAGEAMgA1AGYANQA2AGEAZAAyAGMAZQAzAGEAZgAwADYAZABlAGMAMABjAGIAMQBmADIAZgBhADkAMgAzADYAOAA3ADQAZABhADEAZQA2ADgAMwBiADgAYwA5ADgAOQA5AGEANgBhAGYAYQA1AGEANwAzADIAMQA0AGIANwBhAGMANQBjADcA"
                'alan' = "76492d1116743f0423413b16050a5345MgB8AFgASQA0AFgASAA0AFoAawBTAHIAWABTAEYARABJAGgATQBvADkAZgAvAHcAPQA9AHwAZgAzADQAMgA1ADUAYgBmADAANwBhAGYAOQBlADUANwA5ADMANQA2AGQAZAA2ADQANQBjADEAOQA4ADYAZABiADkANwA4AGYANAAzADYANwBhADkAMgA4AGIAMwA2ADAAYQAwADgAZgBlAGMAMAAwADAAOAAwADMAYwAyADEANwA1ADgANQBlAGEAZQA5ADEAMgA4ADcANwBmAGEAMgBkADAAMgA1ADQAMAA2ADcANABiAGQAOAAyADcANAA0ADgAZAA1ADMAMQBmADYAMABlADAANwAyAGYAZgBiAGEAZAA3ADkANgAwADcANQAzADgAYQA1AGUANwBlADUAYQA1ADEAZQA1ADgAMAA5AGIAOQBhAGEAYwA3ADUAMgA5AGQAMwA5ADcAYQAyADMANABjADEAMgA4AGYAZABkADEAMABmAGEAYwBlADQAMgAwADUAMgBhAGEAYQAzADIAZgAyADcANwA5ADIAOQA3ADEANAAxADAAOQA2AGUANABjADgA"
                'gerard' = "76492d1116743f0423413b16050a5345MgB8AFcAKwBMAFYAMgBWAFkAegBWAG8ANgBKADYAVgB6AHYAegBDAE8ATwA2AFEAPQA9AHwAMABjADAAMwAzADkANwBjADQAYgAzAGYAMABlAGQAZgBiAGUAZABmAGUAOAAzADIANwA3ADkAYwAyADUAZgAyAGYAZAA3AGEANwA5AGMANAA4AGEAZAAyAGQANwAzAGYANgBhADcANABkAGYANwBiAGIAOQBhADQAMwA2ADAAYwA1AGUAMgA0AGYAYQAxAGUAOAA5ADMANABmADEAMgAzADUAMgBiADcANQBjADkAMgBjADcAOABlADgAOQBjADMAYwAzAGYAMwAyADIAOQA1ADkAMgBmADcAMAA1ADAANwA1AGEAMAAyADUAZQBmAGMAMQA2AGUAYQA5AGIAZgA4ADEAMABkADcAZAA3ADcANgBjADQANQBlADcAMQAwAGEAYwA1AGEANwA2ADIAMgAwADEAZQA1AGEAMAA4ADYANABjAGYANgBhAGQAYgAzAGMAYQAyADEAMQA3ADcAYwAzADMANgBhAGIAZgA3ADUAZgA3ADUAYwBmAGMAMwAwAGUA"
                'james' = "null"
            }
            Write-Output "[Interface]" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Output "Address = $($ipEquivalenceVPN[$username])" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Output "DNS = 10.100.0.1" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Output "PrivateKey = $(Decrypt -EncryptedString $encryptedPrivateKeys[$username] -EncryptionKey $Key)" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Output "[Peer]" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Output "AllowedIPs = 10.100.0.1/32, fd08:4711::1/128, 192.168.1.0" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf" #FIND CIDR NOTATION
            Write-Output "Endpoint = grigwood.ml:50009" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Output "PersistentKeepalive = 25" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Output "PublicKey = $(Decrypt -EncryptedString $encryptedPublicKeys[$username] -EncryptionKey $Key)" >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Output "PresharedKey = $(Decrypt -EncryptedString $encryptedPreSharedKeys[$username] -EncryptionKey $Key)"  >> "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf"
            Write-Host "`r[✓] Creating WireGuard config... Done !"
            applyWireGuardConfig -configPath "$userDataDir\ServerDeploy\Ad-Blocking (only DNS is tunnelled).conf" -interface "wg0"
        }
    }
} elseif ($ReConfigure -eq $true) {
    Write-Output "Sussy Baka"
    Start-Sleep 5
}








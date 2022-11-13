param (
    [switch]$NewInstallation = $false,
    [switch]$ReConfigure = $false,
    [string]$lang
)


if (Test-Path -Path "$env:programfiles\Kirkwood Soft"){
    $binairiesDir = "$env:programfiles\Kirkwood Soft"
    $userDataDir = "$env:appdata\Kirkwood Soft"
} elseif (Test-Path -Path "$env:appdata\Kirkwood Soft\binairies") {
    $binairiesDir = "$env:appdata\Kirkwood Soft\binairies"
    $userDataDir = "$env:appdata\Kirkwood Soft\data"
}

$tempDir = "$env:temp"

$enlangmap = @{
    1 = "Welcome to ServerDeploy ! This tool will guide you into configuring your access to the GrigWood server."
    2 = "This device can serve many purposes : "
    3 = "  - storing data, including some automated backups"
    4 = "  - encrypting all your Internet connection "
    5 = "  - completely deleting ads from the pages you visit"
    6 = "  - Download big files off the Internet without heating up your computer"
    7 = "And many more..."
    8 = "So let's start !"
    9 = "Here are all the different components of this system :"
    10 = "    1. SFTPmount : Access the files on the server as if they were on a hard drive connected to your computer"
    11 = "    2. VPN : Encrypt your traffic so hackers can't snoop, get rid of ads on the Internet, and (optional) hide your IP adress"
    12 = "    3. SBackup : Backup folders you select to your dedicated space on the server ⚠️  NOT SUPPORTED YET"
    13 = "    4. SDownload : Download large files off the Internet ⚠️  NOT SUPPORTED YET"
    14 = "Please type in the numbers of the subproducts separated by spaces (and in order, please) "
    15 = "[✗] You have selected option 3 (SBackup), but it requires option 1 (SFTPmount)."
    16 = "Shall we add SFTPmount to list ? [y | n] "
    17 = "[✓] Added SFTPmount to list !"
    18 = "Are you sure ? [y | n] "
    19 = "Exiting in"
    20 = "seconds"
    21 = "Please type in the security key given to you during the training "
    22 = "Downloading rclone"
    23 = "Done"
    24 = "Please enter your server"
    25 = "username"
    26 = "password"
    27 = "[✗] Downloading rclone... Failed : rclone.exe already exists"
    28 = "Folders selection :"
    29 = "  1. Shares"
    30 = "  2. General Storage"
    31 = "  3. Backups"
    32 = "Please type the numbers of the options you wish separated by spaces "
    33 = "Shares"
    34 = "The default place for the Shares folder is"
    35 = "Do you wish to change that ? [y | n]"
    36 = "Please type in the place where you want the Shares folder to be located "
    37 = "Shared folders selection :"
    38 = "Please type in the numbers of the options, separated by spaces "
    39 = "Do you want a shortcut on your Desktop to access your Shares folder (recommended) ? [y | n]"
    40 = "Do you wish to access General Storage as a constantly plugged-in USB Drive (recommended) or as a simple folder ? [d | f] "
    41 = "General Storage will be mounted as"
    42 = "with the label"
    43 = "General Storage"
    44 = "The default place for the General Storage folder is"
    45 = "Do you wish to change that ? [y | n]"
    46 = "Please type in the place where you want the General Storage folder to be located "
    47 = "Do you want a shortcut on your Desktop to access your $($langmap.43)"
    48 = "(recommended) ? [y | n]"
    49 = "Backups will be mounted as"
    50 = "with the label"
    51 = "The default place for the Backups folder is"
    52 = "Do you wish to change that ? [y | n]"
    53 = "Please type in the place where you want the Shares folder to be located "
    54 = "Do you want the folders selected above to be automatically mounted when you start your computer (recommended) [y | n]"
    55 = "Scheduling mounting task :"
    56 = "Configuring scheduled task action"
    57 = "Configuring scheduled task triggers"
    58 = "Configuring scheduled task settings"
    59 = "Applying scheduled task"
    60 = "Alright, a shortcut will be available to start the mounting software manually."
    61 = "This option uses some very good software called WireGuard."
    62 = "Downloading WireGuard installer"
    63 = "The installer is going to ask you if you it to make modifications to your PC. Please answer `"Yes`" to this."
    64 = "Once some big white window pops up, you can close it and come back here."
    65 = "Press any key to continue :"
    66 = "Please type your server username "
    67 = "Please type in the security key given to you during the training "
    68 = "Creating WireGuard config"
    69 = "Make the contents of this folder available offline"
    70 = "Remove folder from offline-access list"
}

$frlangmap = @{
    1 = "Bienvenue sur ServerDeploy ! Cet outil vous guidera dans la configuration de votre accès au serveur GrigWood."
    2 = "Cet appareil peut servir à plusieurs fins : "
    3 = " - stocker des données, y compris certaines sauvegardes automatisées"
    4 = " - chiffrer toute votre connexion Internet "
    5 = " - supprimer complètement les publicités des pages que vous visitez"
    6 = " - Téléchargez de gros fichiers sur Internet sans chauffer votre ordinateur"
    7 = "Et bien d'autres..."
    8 = "Alors commençons !"
    9 = "Voici tous les différents composants de ce système :"
    10 = " 1. SFTPmount : Accédez aux fichiers sur le serveur comme s'ils étaient sur un disque dur connecté à votre ordinateur"
    11 = " 2. VPN : cryptez votre trafic afin que les pirates ne puissent pas espionner, débarrassez-vous des publicités sur Internet et (facultatif) masquez votre adresse IP"
    12 = " 3. SBackup : sauvegarde des dossiers que vous sélectionnez dans votre espace dédié sur le serveur ⚠️ PAS ENCORE SUPPORTÉ"
    13 = " 4. STéléchargement : Téléchargez des fichiers volumineux sur Internet ⚠️ PAS ENCORE SUPPORTÉ"
    14 = "Veuillez saisir les numéros des sous-produits séparés par des espaces (et dans l'ordre, s'il vous plaît)"
    15 = "[✗] Vous avez sélectionné l'option 3 (SBackup), mais elle nécessite l'option 1 (SFTPmount)."
    16 = "Allons-nous ajouter SFTPmount à la liste ? [o | n]"
    17 = "[✓] SFTPmount ajouté à la liste !"
    18 = "Êtes-vous sûr ? [o | n]"
    19 = "Sortie dans"
    20 = "secondes"
    21 = "Veuillez saisir la clé de sécurité qui vous a été remise lors de la formation"
    22 = "Téléchargement de rclone"
    23 = "Terminé"
    24 = "Veuillez entrer votre serveur"
    25 = "nom d'utilisateur"
    26 = "mot de passe"
    27 = "[✗] Téléchargement de rclone... Échec : rclone.exe existe déjà"
    28 = "Sélection des dossiers :"
    29 = " 1. Partages"
    30 = " 2. Stockage général"
    31 = " 3. Sauvegardes"
    32 = "Veuillez saisir les numéros des options souhaitées séparés par des espaces "
    33 = "Partages"
    34 = "L'emplacement par défaut du dossier Partages est"
    35 = "Voulez-vous changer cela ? [o | n]"
    36 = "Veuillez saisir l'endroit où vous souhaitez placer le dossier Partages "
    37 = "Sélection des dossiers partagés :"
    38 = "Veuillez saisir les numéros des options, séparés par des espaces "
    39 = "Souhaitez-vous un raccourci sur votre Bureau pour accéder à votre dossier Partages (recommandé) ? [o | n]"
    40 = "Souhaitez-vous accéder au stockage général en tant que clé USB constamment branchée (recommandé) ou en tant que simple dossier ? [disque | dossier] "
    41 = "Le stockage général sera monté en tant que"
    42 = "avec l'étiquette"
    43 = "Stockage général"
    44 = "L'emplacement par défaut du dossier Stockage général est"
    45 = "Voulez-vous changer cela ? [o | n]"
    46 = "Veuillez saisir l'endroit où vous souhaitez placer le dossier Stockage général "
    47 = "Voulez-vous un raccourci sur votre Bureau pour accéder à votre $($langmap.43)"
    48 = "(recommandé) ? [o | n]"
    49 = "Les sauvegardes seront montées comme"
    50 = "avec l'étiquette"
    51 = "L'emplacement par défaut du dossier Sauvegardes est"
    52 = "Voulez-vous changer cela ? [o | n]"
    53 = "Veuillez saisir l'endroit où vous souhaitez placer le dossier Partages "
    54 = "Souhaitez-vous que les dossiers sélectionnés ci-dessus soient automatiquement montés au démarrage de votre ordinateur (recommandé) [o | n]"
    55 = "Planification de la tâche de mountage :"
    56 = "Configuration de l'action de tâche planifiée"
    57 = "Configuration des déclencheurs de tâches planifiées"
    58 = "Configuration des paramètres de tâche planifiée"
    59 = "Appliquer la tâche planifiée"
    60 = "Très bien, un raccourci sera disponible pour démarrer manuellement le logiciel de montage."
    61 = "Cette option utilise un très bon logiciel appelé WireGuard."
    62 = "Téléchargement du programme d'installation de WireGuard"
    63 = "Le programme d'installation va vous demander si vous souhaitez apporter des modifications à votre PC. Veuillez répondre `"Oui`" à cela."
    64 = "Une fois qu'une grande fenêtre blanche apparaît, vous pouvez la fermer et revenir ici."
    65 = "Appuyez sur n'importe quelle touche pour continuer :"
    66 = "Veuillez saisir le nom d'utilisateur de votre serveur "
    67 = "Veuillez saisir la clé de sécurité qui vous a été remise lors de la formation "
    68 = "Création de la configuration WireGuard"
    69 = "Sauvegarder le contenu du dossier pour un usage hors-ligne"
    70 = "Supprimer ce dossier de la liste des dossiers sauvegardés"
}

# $lang = Read-Host "Language "
# if ($lang -eq "FR"){
#     $langmap = $frlangmap
# }
# if ($lang -eq "EN"){
#     $langmap = $enlangmap
# }

if ((Get-Content -Path "$binairiesDir\LANGUAGE.txt") -eq "FR"){
    $langmap = $frlangmap
    $lang = "FR"
} else {
    $langmap = $enlangmap
    $lang = "EN"
}

function Decrypt {
    Param(
        [Parameter(Mandatory=$True, Position=0, ValueFromPipeLine=$true)] [Alias("String")] [String]$EncryptedString,
    
        [Parameter(Mandatory=$True, Position=1)] [Alias("Key")] [string] $EncryptionKey
    )

    $enc = [system.Text.Encoding]::UTF8
    $byteKey = $enc.GetBytes($EncryptionKey)
    Try{
        $SecureString = ConvertTo-SecureString -String $EncryptedString -Key $byteKey
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
        [Parameter(Mandatory = $false, Position = 0)] [string] $shortcutIconPath,
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
        Write-Host -NoNewline "`r[.] $($langmap.1) $($langmap."$createType") : $createpath ..."
        Start-Sleep -Milliseconds 400
        Write-Host -NoNewline "`r[ ] $($langmap.1) $($langmap["$createType"]) : $createpath..."
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
        } elseif ($createType -eq "shortcut"){
            $WScriptObj = New-Object -ComObject ("WScript.Shell")
            $shortcut = $WscriptObj.CreateShortcut($createpath)
            $shortcut.TargetPath = $shortcutDestPath
            if ($null -ne $shortcutIconPath){
                $shortcut.IconLocation = $shortcutIconPath
            }
            $shortcut.Save()
        }
        Write-Host "`r[✓] $($langmap.1) $($langmap["$createType"]) : $createpath... $($langmap.2)"
    } else {
        Write-Host "`r[✗] $($langmap.1) $($langmap["$createType"]) : $createpath... $($langmap.3) ($($langmap["$createType"]) $($langmap.4))"
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
        Write-Host -NoNewline "`r[ ] $($langmap.5)..."
        $timesofpoint = $timesofpoint + 1
    } until ($timesofpoint -eq 2)
    Remove-Item "$downloadPath" -Force
    Write-Host "`r[✓] $($langmap.5)... $($langmap.2)"

    #format version number
    $versionNumber = $versionCode.replace('v','')
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
    'partageseliasgerard' = "Elias-Gerard"
    'partagesmarianneautres' = "Marianne-Autres"
    'partageseliasjames' = "Elias-James"
    'paratgesmarianneelias' = "Marianne-Elias"
    'partagesgerardautres' = "Gerard-Autres"
    'partagesmariannegerard' = "Marianne-Gérard"
    'partagesgerardjames' = "Gerard-James"
    'paratgesalanjames' = "Alan-James"
    'partagesjuliettemarianne' = "Juliette-Marianne"
    'partagesjuliettealan' = "Juliette-Alan"
    'partagesjulietteautres' = "Juliette-Autres"
    'partagesalanautres' = "Alan-Others"
    'partagesjulietteelias' = "Juliette-Elias"
    'partagesalanelias' = "Alan-Elias"
    'partagesjuliettegerard' = "Juliette-Gérard"
    'partagesalangerard' = "Alan-Gerard"
    'partagesjuliettejames' = "Juliette-James"
    'partagesjamesautres' = "James-Others"
    'partageseliasautres' = "Elias-Others"
    'partagesmariannealan' = "Marianne-Alan"
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
Write-Output $($langmap.1)
Write-Output $($langmap.2)
Write-Output $($langmap.3)
Write-Output $($langmap.4)
Write-Output $($langmap.5)
Write-Output $($langmap.6)
Write-Output $($langmap.7)
Start-Sleep 5
Write-Output " "
Write-Output $($langmap.8)
Write-Output " "
Write-Output "-----------------------------------------------------------------"


if ($NewInstallation -eq $true){
    Write-Output $($langmap.9)
    Write-Output $($langmap.10)
    Write-Output $($langmap.11)
    Write-Output $($langmap.12)
    Write-Output $($langmap.13)
    $serverInstallOptionsList = Read-Host $($langmap.14)
    $serverInstallOptionsArray = $serverInstallOptionsList.Split(" ")

    if (($serverInstallOptionsArray.Contains("3")) -and (-not ($serverInstallOptionsArray.Contains("1")))){
        Write-Output " "
        Write-Output $($langmap.15)
        $addSFTPmount = Read-Host $($langmap.16)
        if (($addSFTPmount -eq "y") -or ($addSFTPmount -eq "o")){
            $serverInstallOptionsArray = $serverInstallOptionsArray + '1'
            Write-Output $($langmap.17)
        } else {
            $confirm = Read-Host $($langmap.18)
            if (($confirm -eq "y") -or ($confirm -eq "o")){
                $time = 5
                do {
                    Write-Host -NoNewline "`r$($langmap.19) $time $($langmap.20)..."
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
        $currentDataFolder = "$userDataDir\ServerDeploy\$($productEquivalenceMap["$serverInstall_currentOption"])"
        creatingLoading -createType "directory" -createpath "$currentDataFolder" -lang $lang
        if ($serverInstall_currentOption -eq "1"){
            $token = "76492d1116743f0423413b16050a5345MgB8AFMAaABOAE4AeQBOAHAAOQBEAHEANABFAGUANwBjAHoAeQBGAC8AVgBuAFEAPQA9AHwAOQBiAGQAZgBmAGUANwBmADgAYQBlAGYANwA2AGUAMwBiAGQAYQBiAGIANwAzAGYAZABhADQANABlADMAOQA2ADkAYQA0ADUAMABlADIAMABhADkAOQBiADMAOAAwAGIAMABmAGEAMwA2ADcANwAwADUANwBjAGYAMwAzADYANQBmADIAYQAxADMANQBkAGYAZgA1ADcAOQAwADcAYgBjADUAMgBjAGMAYwBhAGMAMQAwADAAMQBhADcAMgBlAGMAZgAxADQANQA2AGEANQBjADkAOABiAGUANQBmAGUAOABjADgANgA3AGIANwA4ADkAZgBhADcANgA5ADAAMwAxAGMAMgBlADAAZQBkADEAMAAwAGQAZgBhADgAOQA2AGQAOQAyAGMANAA3ADAAZgAxAGYAOQA2AGYAMwBmADUAYwA0ADcAYgAzAGUAMQA1AGYAMwAxADcAZAA1ADUAYgA3AGQAYwBjAGQANgAzAGEAMAA2ADQAMABmAGEAZgA4AGEA"
            $key = Read-Host $($langmap.21)
            dlGitHub -repo "ServerDeploy" -file "mounter.exe" -lang $lang -endLocation "$currentFolder" -token "$token" -key "$key"
            dlGitHub -repo "ServerDeploy" -file "mount.vbs" -lang $lang -endLocation "$currentFolder" -token "$token" -key "$key"
            dlGitHub -repo "ServerDeploy" -file "addToCache.ps1" -lang $lang -endLocation "$currentFolder" -token "$token" -key "$key"
            dlGitHub -repo "ServerDeploy" -file "removeFromCache.ps1" -lang $lang -endLocation "$currentFolder" -token "$token" -key "$key"
            dlGitHub -repo "ServerDeploy" -file "icons.zip" -lang $lang -endLocation "$currentFolder\icons" -token "$token" -key "$key"
            creatingLoading -createType "directory" -createpath "$currentDataFolder\submounts" -lang $lang -createname "submounts"
            $null = New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.addToCache"
            $null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.addToCache" -Name "(Default)" -Value "$($langmap.69)" -Force
            $null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.addToCache" -Name "icon" -Value "%SystemRoot%\System32\imageres.dll,233" -PropertyType "String"
            $null = New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.addToCache\command"
            $null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.addToCache\command" -Name "(Default)" -Value "powershell.exe -WindowStyle Hidden -File `"$currentFolder\addToCache.ps1`" -path `"%1`" -csv `"C:\Users\Elias Kirkwood\AppData\Roaming\Kirkwood Soft\data\ServerDeploy\SFTPmount\cache.csv`" -cache `"C:\Users\Elias Kirkwood\AppData\Roaming\Kirkwood Soft\data\ServerDeploy\SFTPmount\offline_cache`" -lang $lang"
            $null = New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.RemoveFromCache"
            $null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.RemoveFromCache" -Name "(Default)" -Value "$($langmap.70)" -Force
            $null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.RemoveFromCache" -Name "icon" -Value "%SystemRoot%\System32\imageres.dll,232" -PropertyType "String"
            $null = New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.RemoveFromCache\command"
            $null = New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell\Custom.removeFromCache\command" -Name "(Default)" -Value "powershell.exe -WindowStyle Hidden -File `"$currentFolder\removeFromCache.ps1`" -path `"%1`" -csv `"C:\Users\Elias Kirkwood\AppData\Roaming\Kirkwood Soft\data\ServerDeploy\SFTPmount\cache.csv`" -cache `"C:\Users\Elias Kirkwood\AppData\Roaming\Kirkwood Soft\data\ServerDeploy\SFTPmount\offline_cache`" -lang $lang"
            $null = New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
            $null = New-Item -Path "HKCR:\Directory\shell\Kirkwood Soft"
            $null = New-ItemProperty -Path "HKCR:\Directory\shell\Kirkwood Soft" -Name "icon" -Value "%SYSTEMROOT%\system32\shell32.dll,149" -PropertyType "String"
            $null = New-ItemProperty -Path "HKCR:\Directory\shell\Kirkwood Soft" -Name "MUIVerb" -Value "SFTPMount" -PropertyType "String"
            $null = New-ItemProperty -Path "HKCR:\Directory\shell\Kirkwood Soft" -Name "SubCommands" -Value "Custom.addToCache;Custom.removeFromCache" -PropertyType "String"
            if ((Test-Path -Path "$binairiesDir\ServerDeploy\SFTPmount\rclone.exe" -PathType Leaf) -eq $false){
                $dlRclone = Start-Job -ScriptBlock {
                    param (
                        $tempDir
                    )
                    curl.exe -o "$tempDir\rclone.zip" https://downloads.rclone.org/rclone-current-windows-amd64.zip
                } -ArgumentList $tempDir
                do {
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[.] $($langmap.22)..."
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[ ] $($langmap.22)..."
                    $timesofpoint = $timesofpoint + 1
                } until ($dlRclone.State -eq "Completed")
                Expand-Archive -Path "$tempDir\rclone.zip" -DestinationPath "$tempDir\rclone" -Force
                $rcloneExe = Get-ChildItem -Path "$tempDir\rclone" -Filter "rclone.exe" -Recurse | ForEach-Object{$_.FullName}
                Copy-Item -Path "$rcloneExe" -Destination "$binairiesDir\ServerDeploy\SFTPmount\rclone.exe" -Force
                Remove-Item -Path "$tempDir\rclone\*" -Recurse -Force
                Remove-Item -Path "$tempDir\rclone.zip"
                Write-Host "`r[✓] $($langmap.22)... $($langmap.23) !"
                creatingLoading -createType "directory" -createpath "$env:appdata\rclone" -createname "rclone" -lang "$lang"
            } else {Write-Host $langmap.27}
            $username = Read-Host "$($langmap.24) $($langmap.25) "
            $password = Read-Host "$($langmap.24) $($langmap.26) "
            creatingLoading -createType "file" -createpath "$env:appdata\rclone\rclone.conf" -createname "rclone.conf" -lang "$lang"
            $null = cmd.exe /b /c "`"$binairiesDir\ServerDeploy\SFTPmount\rclone.exe`" config create sftp-nas sftp host `"grigwood.ml`" port `"50007`" user `"$username`""
            $null = cmd.exe /b /c "`"$binairiesDir\ServerDeploy\SFTPmount\rclone.exe`" config password sftp-nas pass `"$password`""
            Write-Output " "
            Write-Output $langmap.28
            Write-Output $langmap.29
            Write-Output $langmap.30
            if ($username -ne "elias"){
                Write-Output $langmap.31
            }
            $NASfoldersOptions_list = Read-Host $langmap.32
            $NASfoldersOptions_array = $NASfoldersOptions_list.Split(" ")
            foreach ($NASfoldersOptions_current in $NASfoldersOptions_array){
                if ($NASfoldersOptions_current -eq '1'){
                    $shareLocation = "$env:userprofile\$($langmap.33)"
                    Write-Output "$($langmap.34) $env:userprofile."
                    $changesharesplace = Read-Host $langmap.35
                    if (($changesharesplace -eq "y") -or ($changesharesplace -eq "o")){
                        $shareLocation = Read-Host $langmap.36
                    }
                    creatingLoading -createType "directory" -createpath "$shareLocation" -lang "$lang" -createname "Shares"
                    Write-Output " "
                    Write-Output "-----------------------------------------------------------------"
                    Write-Output $langmap.37
                    Write-Output "1. $($langmap.33) Elias-Gérard                     11. $($langmap.33) Juliette-Autres"
                    Write-Output "2. $($langmap.33) Marianne-Autres                  12. $($langmap.33) Alan-Autres"
                    Write-Output "3. $($langmap.33) Elias-James                      13. $($langmap.33) Juliette-Elias"
                    Write-Output "4. $($langmap.33) Marianne-Elias                   14. $($langmap.33) Alan-Elias"
                    Write-Output "5. $($langmap.33) Gérard-Autres                    15. $($langmap.33) Juliette-Gérard"
                    Write-Output "6. $($langmap.33) Marianne-Gérard                  16. $($langmap.33) Alan-Gérard"
                    Write-Output "7. $($langmap.33) Gérard-James                     17. $($langmap.33) Juliette-James"
                    Write-Output "8. $($langmap.33) Alan-James                       18. $($langmap.33) James-Autres"
                    Write-Output "9. $($langmap.33) Juliette-Marianne                19. $($langmap.33) Elias-Autres"
                    Write-Output "10. $($langmap.33) Juliette-Alan                   20. $($langmap.33) Marianne-Alan"
                    Write-Output " "

                    $shareoptions = Read-Host $langmap.38

                    $shareoptionsarray = $shareoptions.split(" ")
                    $outshareoptionsarray = $shareoptionsarray | ForEach-Object {
                        $selectedshareoption = $_;
                        Write-Output $shareoptionequivalencemap[$selectedshareoption]
                    }
                    foreach ($outshareoptions_current in $outshareoptionsarray){
                        creatingLoading -createType "file" -createpath "$currentDataFolder\submounts\$outshareoptions_current.bat" -createname "$outshareoptions_current.bat" -lang "$lang"
                        Add-Content -Path "$currentDataFolder\submounts\$outshareoptions_current.bat" -Value "`"$currentFolder\rclone.exe`" mount sftp-nas:/$outshareoptions_current `"$shareLocation\$($langmap.33) $($sharenameequivalencemap[$outshareoptions_current])`" --vfs-cache-mode writes"
                    }
                    $shortcut = Read-Host $langmap.39
                    if (($shortcut -eq "y") -or ($shortcut -eq "o")){
                        $desktop = [Environment]::GetFolderPath('Desktop')
                        creatingLoading -createType "shortcut" -createpath "$desktop\$($langmap.33)s.lnk" -shortcutDestPath "$shareLocation" -shortcutIconPath "shell32.dll,158" -lang $lang
                    }
                }
                if ($NASfoldersOptions_current -eq '2'){
                    $generalAS = Read-Host $langmap.40
                    if (($generalAS -eq "d") -or ($generalAS -eq "disque")) {
                        $type = "drive"
                        $generalLocation = "S:"
                        if ((Test-Path -Path "$generalLocation") -eq $true) {
                            $generalLocation = Get-ChildItem function:[h-z]: -n | Where-Object{ !(test-path $_) } | Select-Object -First 1
                        }
                        Write-Output "$($langmap.41) $generalLocation $($langmap.42) `"$($langmap.43)`""
                    } else {
                        $type = "folder"
                        $generalLocation = "$env:userprofile\General Storage"
                        Write-Output "$($langmap.44) $env:userprofile."
                        $changegeneralplace = Read-Host $langmap.45
                        if (($changegeneralplace -eq "y") -or ($changegeneralplace -eq "o")) {
                            $generalLocation = Read-Host $langmap.46
                        }
                    }
                    creatingLoading -createType "file" -createpath "$currentDataFolder\submounts\mountgeneral$username.bat" -createname "mountgeneral$username.bat" -lang "$lang"
                    if ($type -eq "drive"){
                        Add-Content -Path "$currentDataFolder\submounts\mountgeneral$username.bat" -Value "`"$currentFolder\rclone.exe`" mount sftp-nas:/general-$username `"$generalLocation`" --volname `"$($langmap.43)`" --vfs-cache-mode writes" 
                    } elseif ($type -eq "folder"){
                        Add-Content -Path "$currentDataFolder\submounts\mountgeneral$username.bat" -Value "`"$currentFolder\rclone.exe`" mount sftp-nas:/general-$username `"$generalLocation`" --vfs-cache-mode writes" 
                    }
                    
                    $shortcut = Read-Host "$($langmap.47) $type $($langmap.48)"
                    if (($shortcut -eq "y") -or ($shortcut -eq "o")){
                        $desktop = [Environment]::GetFolderPath('Desktop')
                        creatingLoading -createType "shortcut" -createpath "$desktop\$($langmap.43).lnk" -shortcutDestPath "$generalLOcation" -shortcutIconPath "shell32.dll,149" -lang $lang
                    }
                }
                if ($NASfoldersOptions_current -eq "3"){
                    $backupsAS = Read-Host "Do you wish to access Backups as a constantly plugged-in USB Drive (recommended) or as a simple folder ? [d | f] "
                    if (($backupsAS -eq "d") -or ($backupsAS -eq "disque")){
                        $type = "drive"
                        $backupsLocation = "B:"
                        if ((Test-Path -Path "$backupsLocation") -eq $false) {
                            $backupsLocation = Get-ChildItem function:[i-z]: -n | Where-Object{ !(test-path $_) } | Select-Object -First 1
                        }
                        Write-Output "$($langmap.49) $generalLocation $($langmap.50) `"Backups`""
                    } else {
                        $type = "folder"
                        $backupsLocation = "$env:userprofile\Backups"
                        Write-Output "$($langmap.51) $env:userprofile."
                        $changebackupplace = Read-Host $langmap.52
                        if (($changebackupplace -eq "y") -or ($changebackupplace -eq "o")){
                            $backupsLocation = Read-Host $langmap.53
                        }
                    }
                    $backupname = $username + "-backup"
                    creatingLoading -createType "file" -createpath "$currentDataFolder\submounts\mountbackups$username.bat" -createname "mountbackups$username.bat" -lang "$lang"
                    if ($type -eq "drive"){
                        Add-Content -Path "$currentDataFolder\submounts\mountbackups$username.bat" -Value "`"$currentFolder\rclone.exe`" mount sftp-nas:/$backupname `"$backupsLocation`" --volname `"Backups`" --vfs-cache-mode writes"
                    } elseif ($type -eq "folder"){
                        Add-Content -Path "$currentDataFolder\submounts\mountbackups$username.bat" -Value "`"$currentFolder\rclone.exe`" mount sftp-nas:/$backupname `"$backupsLocation`""
                    }
                    $shortcut = Read-Host "$($langmap.47) $type $($langmap.48)"
                    if (($shortcut -eq "y") -or ($shortcut -eq "o")){
                        $desktop = [Environment]::GetFolderPath('Desktop')
                        creatingLoading -createType "shortcut" -createpath "$desktop\Backups.lnk" -shortcutDestPath "$backupsLocation" -shortcutIconPath "shell32.dll,6" -lang $lang
                    }
                }
            }
            $autoMount = Read-Host $langmap.54
            if (($autoMount -eq 'y') -or ($autoMount -eq 'o')){
                Write-Output " "
                Write-Output "-----------------------------------------------------------------------"
                Write-Output $langmap.55
                $timesofpoint = 0
                do {
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[.] $($langmap.56)..."
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[ ] $($langmap.56)..."
                    $timesofpoint = $timesofpoint + 1
                } until ($timesofpoint -eq 2)
                $scheduledAction = New-ScheduledTaskAction -Execute "$currentFolder\mount.exe" -Argument "`"$currentFolder\mount.vbs`" `"$currentDataFolder\submounts`" `"$currentDataFolder\offline_cache`" `"$userDataDir\ServerDeploy\$($productEquivalenceMap["$serverInstall_currentOption"])\cache.csv`" `"$lang`""
                Write-Host "`r[✓] $($langmap.56)... $($langmap.23) !"
                $timesofpoint = 0
                do {
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[.] $($langmap.57)..."
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[ ] $($langmap.57)..."
                    $timesofpoint = $timesofpoint + 1
                } until ($timesofpoint -eq 2)
                $scheduledTrigger = New-ScheduledTaskTrigger -AtLogOn -User $env:UserName
                Write-Host "`r[✓] $($langmap.57)... $($langmap.23) !"
                $timesofpoint = 0
                do {
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[.] $($langmap.58)..."
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[ ] $($langmap.58)..."
                    $timesofpoint = $timesofpoint + 1
                } until ($timesofpoint -eq 2)
                $scheduledSettings = New-ScheduledTaskSettingsSet -DontStopIfGoingOnBatteries -AllowStartIfOnBatteries
                Write-Host "`r[✓] $($langmap.58)... $($langmap.23) !"
                $timesofpoint = 0
                do {
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[.] $($langmap.59)..."
                    Start-Sleep -Milliseconds 400
                    Write-Host -NoNewline "`r[ ] $($langmap.59)..."
                    $timesofpoint = $timesofpoint + 1
                } until ($timesofpoint -eq 2)
                $scheduledTask = New-ScheduledTask -Action $scheduledAction -Trigger $scheduledTrigger -Settings $scheduledSettings -Description "Program to automatically mount your server folders (whether they are online or offline) when you start your PC."
                $null = Register-ScheduledTask -TaskName 'SFTPmount' -InputObject $scheduledTask -User $env:UserName
                Write-Host "`r[✓] $($langmap.59)... $($langmap.23) !"
            } elseif ($autoMount -eq 'n'){
                Write-Output $langmap.60
            }
        }
        if ($serverInstall_currentOption -eq "2"){
            Write-Output = $langmap.61
            $dlWG = Start-Job -ScriptBlock {
                param (
                    $tempDir
                )
                curl.exe -o "$tempDir\wireguard-installer.exe" https://download.wireguard.com/windows-client/wireguard-installer.exe
                } -ArgumentList $tempDir
            do {
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[.] $($langmap.62)..."
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[ ] $($langmap.62)..."
                $timesofpoint = $timesofpoint + 1
            } until ($dlWG.State -eq "Completed")
            Write-Host "`r[✓] $($langmap.62)..."
            Write-Output $langmap.63
            Write-Output $langmap.64
            Start-Sleep 3
            Start-Process "$tempDir\wireguard-installer.exe"
            Start-Sleep 10
            Write-Output $langmap.65
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
            Remove-Item "$tempDir\wireguard-installer.exe"
            $username = Read-Host $langmap.66
            $Key = Read-Host $langmap.67
            $timesofpoint = 0
            do {
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[.] $($langmap.68)..."
                Start-Sleep -Milliseconds 400
                Write-Host -NoNewline "`r[ ] $($langmap.68)..."
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
                'elias' = "76492d1116743f0423413b16050a5345MgB8ADMAOQBuADYAZQBnADAAaQBoAE4AVAAwAGMAYwB1AGwAUAA4AGQAcwB4AGcAPQA9AHwAYgA2AGQAYwBkADkAYgBjADEAOAA1AGYAMQBhAGUAYwBmADkAMwA0ADMAMgA2ADEANwAxADYAYQBiAGYANgBmADYAMQA4ADEAMQA5ADQAZgBhADMAZABkAGIAYQA3ADgAZQBiADcAOAA1AGIAZQAzADIAYwBhADYAYgBkADIAYgA3ADIANQBlADkAYQA4ADQAMQBjADUAZAAxAGYAYwBmADgAZAA1ADQAYQBlADAANwBiAGIANQBlAGMAOQBjAGMAMQBjADgAYQA4AGYAMAA3ADEANQA4ADYANABkADcANgBmAGYAYgA4ADMAYQBiADAAZgBjADgANABlADIAMQA3AGIAZAA5ADMAMQAxAGMANgA3ADEANwA2ADcAMQAzADQAMwAzAGQANgAyADcAOABiAGYANgAzADgAZgBmADAAZgBiADUAMwA1ADUANQA5AGMAYgA3ADMAOQBhADcAMwBiADMANwA1AGEAMgA3ADQAMABlADMAMgBiADMAZAA3AGMA"
                'marianne' = "76492d1116743f0423413b16050a5345MgB8AE0AVgB0AHAAaABnAEoATQBSAEUAMgB3AEsAcwA5AFEAVQBmAFAAawBIAEEAPQA9AHwAOAA4ADEAZAAyADIAOQA4ADYAMQAzAGIAZQA2AGQAMQAxADQAZAAxAGYAOQBjADQANQAzADEANAA5AGMAYQA2ADcAMQA2ADMAMgAxADYANgBjAGQAMgAxAGYAZAA0ADgANwA3AGQAZgA1AGYAMwBiADcANgBmADMAOAA4ADcAYQAyADMAYQBiADAAMAA2ADMAZQA2ADkANwA2ADUANQBkAGQANgAwAGYAYQA3ADEAMgBlADUANwAwADMANgAyAGUANgBjADYAYwBiAGQANgA1ADkAYgBlAGMAMAAwADYAZQA4ADUAZAAzADgAMgAyADQANABmAGYAYQAwADcAYQBkADIAMQBjADgAZQA2AGIAYgAwADgAMwA4ADMANAAyADUAZQA2ADgANQBhADIANAA0AGQAYQA0ADMANAAyADYAYgBiAGQAYgBiAGYAMQAwADAANwBhAGMAMgA0ADYANgA1AGQAMgA4ADEANABlAGQANgBhADAANQAxAGUAMQBjAGUA"
                'juliette' = "76492d1116743f0423413b16050a5345MgB8AEgASQB6AHMANQBpAHUAMABoAGgAbABMAFgAOQA4AFQAUQBrAFAALwBvAFEAPQA9AHwAMwAyADcAMgBiADAAYgA4AGYAMQAyADUAYgBlAGIANABmADEANgA2ADcAYwBmADkAOQA1AGIAYwBhADUANQA1AGYAZQAwAGUANgAzADUAMgAxADQANgA2ADkAOQBlADIAZQA3ADkANQAxAGQAMAAzADEANAA1ADEANAAxADIAMwA0ADUANgBhADIAOABkAGQAZAA3AGIAMQA1ADMAMABiAGIANwA4AGMAMQAzAGYANwAxAGEANQA0ADIAZgA2AGEAOQBkADEANwA1ADMAYgAwADEAMQBkADYAMgA4ADkANQA3ADYANgA3ADEANQAwADcAMAA0AGYAMQBkADYANgA3ADIAMwAwADYAOQBmADEAYQAyADUAZgA4ADIANwA4ADYAMQA3AGMANwAwADUAMQBiADMAYQA2AGQAMAA2ADcAZAAzAGIANgA1ADMANABmADAAZAAwADYAMwBhADMAMAAwADEAYwBhAGMAZQAwAGIAZABhAGQAYwA0AGIANwBmADAA"
                'alan' = "76492d1116743f0423413b16050a5345MgB8ADMAOQBuADYAZQBnADAAaQBoAE4AVAAwAGMAYwB1AGwAUAA4AGQAcwB4AGcAPQA9AHwAYgA2AGQAYwBkADkAYgBjADEAOAA1AGYAMQBhAGUAYwBmADkAMwA0ADMAMgA2ADEANwAxADYAYQBiAGYANgBmADYAMQA4ADEAMQA5ADQAZgBhADMAZABkAGIAYQA3ADgAZQBiADcAOAA1AGIAZQAzADIAYwBhADYAYgBkADIAYgA3ADIANQBlADkAYQA4ADQAMQBjADUAZAAxAGYAYwBmADgAZAA1ADQAYQBlADAANwBiAGIANQBlAGMAOQBjAGMAMQBjADgAYQA4AGYAMAA3ADEANQA4ADYANABkADcANgBmAGYAYgA4ADMAYQBiADAAZgBjADgANABlADIAMQA3AGIAZAA5ADMAMQAxAGMANgA3ADEANwA2ADcAMQAzADQAMwAzAGQANgAyADcAOABiAGYANgAzADgAZgBmADAAZgBiADUAMwA1ADUANQA5AGMAYgA3ADMAOQBhADcAMwBiADMANwA1AGEAMgA3ADQAMABlADMAMgBiADMAZAA3AGMA"
                'gerard' = "76492d1116743f0423413b16050a5345MgB8AFYARQBaAHkAVQBpADMAUABuADgAegB1ADMAWQB0AGoAeQAzAHcAdgB4AFEAPQA9AHwAMgBmAGQAYwAyADEANwA2ADgAMQA1AGEAZQBiADAAZQAxAGIAMQBiAGIAMAAyADUAZgA3ADQAMABjADYANAAzADQAMAAyADgAOABmAGQAZgAzADUANgAxADcANwBkAGMAZQBjADQAYwBmAGMANABiADgAZAAxAGEANAA5AGQAOQA2ADkAMgA2AGQAYQA3AGUAYwA5AGYANwAzADgANABiADUAYgAwAGEAZgA5ADMANwA5ADgANQBkADIAMwBjAGEAOQA3ADgAYQBmADcAMwBmAGEAOAA1ADQAYwBkADIAZABmAGIANABiADMAYgA5AGEANgA0ADUAMgA5ADMAZAAwAGYAOQBiADQANwBmADYANAA4ADIAMwA4AGMAZgBiADAAOQBiADcAZAAwADIAYgBhADYAMgA0AGQAMwA3ADkAMQBiADgANwBiADYAMgA0AGYANwBlADQANgA3ADYAMQA0AGQAMQBiADMAZQBhAGYAMwBjADkANgBkADgAZAAzADcA"
                'james' = "76492d1116743f0423413b16050a5345MgB8AFEAMgBVAFoARQBvAEQAcgByAE0AdQBOAGsAWQBaAE4AOQBuAEgATQBhAGcAPQA9AHwANQA0AGYAMQA3ADUAOABkADEANgBiADkAZgBjADkANgBkAGIAMgA4ADEAYwAzAGEANABkAGUAMQA1ADEANAA3AGUAYwBhAGEAMQA2ADcAYwAxAGMAZABlADEANgBkADEAOQBmADQAMQBiADIAMgBiADcAMgAxADMAZQA5AGEANAA5ADgAYQA1ADgAZAAyADAAMQBhADQAMgBhADYAZAA2AGEANwBiADIAYgA3AGIAMABiADMAOQAxADEAOAA0ADAANQBhAGYAZgBhADUANAA0ADIAOQAyADIANwA2ADMAZABhADMAMABmADQAYgBkAGEAMgBjADkAOQAzADIANQA4AGEAMwA5ADUAZAA4AGUAZAA1ADUAZAA4AGIAZQBhADMAYQAzADUAMwA2ADEAMgA4ADAAYQAzADkAMwA2ADEAYgBjAGEAYwAwADIAMABiAGIANAAyADAAOQA0ADMANAA5AGMAYwBkADYANgA2ADYAMwA2ADgANwA4ADEAZgA1ADUA"
            }
            $encryptedPrivateKeys = @{
                'elias' = "76492d1116743f0423413b16050a5345MgB8AC8AawBTAGkAUgBqADMALwBxAGEAVwBhAGIAbQBoADMAVwBNAEwARwB5AHcAPQA9AHwAMgBjAGQAMAA2ADEAZAAzADgAZAAzADkANABkADQAYwA4ADYAZQA5ADgANAAzAGQANgBjADAAOQA3AGEAOABhADMANQA3ADUAMgA5AGQAYwA4AGEAZgA4AGYAYgBhAGIANgBlADQAMQAwADcAMAA2ADMAYgBkADIAYgBkADQANABhADUANgA1AGYANQBhADkANgAwADAAYwBhADgANAAzAGUAZgBmADcANQA0ADUAMwAzAGMAMgAzAGEAOQA0ADgAYgA4ADQAOQA3AGYANAA5AGQANgA1ADAAMwA0ADQAYQBkAGMAOQBjADEAZgAzAGMAMABmADQAOQBiAGQANABjADIAOQA3ADIAMgA4ADIAYwBjADQAOQA1AGQAYgA4AGYAYgBkAGYAYQAwAGEAZgA3AGMAOQBmADMANgA5ADcAMgA0AGIAZQA5ADYAZQAwAGEAZQBjADUAZABlAGMAMAAyADcAMQA4ADAANgAxADUAMwAwADQANwBlADYAZgAwAGEA"
                'marianne' = "76492d1116743f0423413b16050a5345MgB8AC8ARgBPADMAdgBaAGYAMAB1AEYANABQAHMANQBVAHMAZQBBAGsAVQBLAEEAPQA9AHwAZAAxADUAZgA5AGIAOQBiADEAMwA0AGQAMQA3AGUAZQAxADUAZABmAGEAYQBiADUAYQBhAGYAMAA1AGIAZQAwADkANQBiAGYAMQA2ADMAZQA3ADcAOAAzAGIAZAA1AGUAZgAwAGYAYgA0AGQAMQBlADUAYQA3AGIAOQBjADEAOABjAGMAYwAwAGUAZgAzADMAYwA4AGUANgBjADQANgA5ADMAMAA1ADYAYwBlADIAMwA4ADIANgBmAGMAOQA4ADAAOQA5AGYAYgA2ADUANAA0AGIAOABiADYAMgAwADUANwBkADcAZQBmADkAYwA5ADAANABlADMAOAAxADAAZABmAGUAOAA1ADcAYwAwAGIAMwA4AGEANwAzAGIAZgBlAGYAOQA3ADIANgAwADYANgAwAGIAMwBjADAAOQBhADkANQBjADcAMABkADMAZgA0AGQAYwA4AGEANQA1ADQAOQA4ADkAZABmADgAMwA3ADQAYgA0AGMAZQA3AGYAZgAxADMA"
                'juliette' = "76492d1116743f0423413b16050a5345MgB8AGMAQQBoAGYAbwBLAEwAcQBLAHIAZQBiAEsAdgByACsAbwBpAGgAVAAxAHcAPQA9AHwAZQA0ADAAMwAzADQANQAyADQAYwA4ADIANgAzADIAOABjAGQAYQBhADUAYwBiADYANAA3ADIAZQAzAGEAYgA0ADAAOQA5ADgAMQA1ADkAMgAyADkANABiAGUAZgA4ADYANQA0AGMANwBkADAAOAA4ADUANQAxADcAYQA5AGMANgAxAGUAMABkAGUAOQA5ADkAYQBhAGIAMAA1ADUAMgAxADIAMgBiADYANQA1ADEAZAA0AGYAYQAyADkAOABiAGQAYgBiAGMAMgA4ADQAMAAyAGUAMwBiADUAOQAxADMANgBhADQANgAyAGQAOQA5ADYAMwAzADcAZQAxAGMAZQA2ADQANQA5ADYAMABjAGUAMABjADQAMQBjADAAOQA3AGMAMQAzAGEAOQBhAGQAMAA2AGEAZABkADAAMABlADMAYgBmADUAZQBiADcAZAA1ADEAZQBlAGMANgBlADUAYQBkAGUAZgBmAGYAYwAwADcAZQA1ADAAZgAyADUAMQA2ADUA"
                'alan' = "76492d1116743f0423413b16050a5345MgB8AGkAeABuAHQAZgBoAHcAOQB2AGYAbAByADQAdAB2ADAAWgBhAFYAVQBNAHcAPQA9AHwAYwA1AGQANgA3ADAAOAA2ADMAYwA2ADkAOQAxADcAZQBjAGYAYQBlADMAMQA1AGYANQAwADIAMwBkAGUANQAwAGQAMgAzADcANwAyAGIAMwAwADIAMwAzADUANwA3AGIAZQBiADIANgA3ADMAMgAyAGEAOQAwAGUAZQBkADgANwA2ADAAYQAxADAANgAyAGIAMAA3ADgAOAA4ADIAYQBjAGUAZgA4ADIAMQBlAGMAMgA1AGUAMQA2ADQAOABlAGEANwBkADgAMwAzADQAZgA0AGEAOQAyAGYAZAA4ADIAZAAxAGMANABmAGUANQAyADAAMgA1AGEANQBmADYAMwAyADUAZQAwADMAYgAyAGYAYgBhAGIAYwAwADEAMgA4ADEANwBhADMANQA2ADkAYQA5ADYAZQBkADgAZQA5ADYAMQAxADUAYgBmAGEAYQBkADcAMQAyAGMANAAyADAAYgAzADMANwBjAGUAZgAxADYAMgAxADMANQAyADAANQBhADcA"
                'gerard' = "76492d1116743f0423413b16050a5345MgB8AHoASwBqAFIAZwBWAHQAYgBpAGUARABWAFoAKwBaAHoAbwB3ADEASAB2AEEAPQA9AHwAOAAyADgAYQA2ADUAYwBiAGQANgBhAGQAYQA4ADEANAA4AGQAMwA1ADIAZgA1ADYAYQAxADcAZABhADYANwBhADMAYgAyADkAMgBjADMAZAA4ADEAMgBlADkAOABkAGMAYQA2AGQAZgBhADMAYgA3ADkAYQBkADUAMgBkAGIAZgA5ADUAOQBhADYAYwBkAGUAZAA5AGYAMAAyADUAMwA5AGQAYwA0AGMAMwBmADkAYQA5AGYAZQA2ADUAMgBiADYAZgAzADgANgA3AGQAOQAyAGUANgAwAGUAMQA3ADkAMAA3ADkANgA0AGMAMwBjADQAZAA3ADEANgAxADgAMAAwAGYANQA1ADgAMQA5ADYAZAA1ADUAZAA3ADUAMQA0ADEAYQA3ADcAZAA5ADcAOQA4ADEAMwAwADUAOQBkADAAZAAzADYAOQBlAGUAOQA3ADIAMQA0ADAAMQA4ADgAYgAwADcAYQA5ADkAYwA0ADMANAA0ADkAOQAxADEAZAA1ADIA"
                'james' = "76492d1116743f0423413b16050a5345MgB8AEUAcwB1AHkAMABMAHIAdABFAGEAMQBHAHoARABSAGEASABmAEkAQwB4AFEAPQA9AHwAZAA2ADAAZgA2ADMAMgA4AGYAMwA3AGYAMwBhADMAMwBkAGEANgAxADMAYQA0ADcANwA2ADkAZABlADUAOAA0ADEANQBjAGIAYgAzADYAMgAwADcAYwBkADAAOAA2ADEAYwAwAGEAZgA2ADMAOQA3AGUANwBlADYANQBkAGQAOAA5AGUAOQBmAGUAOAAxADEAYQBhADUAMQBjAGEAYwBiADkAYgA2ADIAMwBkADkAMwAwADIAZAAzAGEAOAAxAGYANAA4ADkAOQA0ADcAMAA2AGMAYwBmADYAMgA4ADUAZABhAGEAYgBmAGMAMQA1AGYAOAA3AGMAYgA4ADIAYQBlADUANQBmADgANQAwADQAOAA5AGUAYgAzADcAMgA2AGUANwBmADcAYwAwAGEANgA0ADAAYwBhAGIAZAAzADMAYgA5ADYAMQAyAGEAMwAyAGUAZgAyADAAYQBjAGQAOQA5AGUAMgBjADIAYwA1ADQAMQAyADEAZABhADkAMAA2ADgA"
            }
            $encryptedPreSharedKeys = @{
                'elias' = "76492d1116743f0423413b16050a5345MgB8AFkAeQBLAGsAWAAzACsAbAA2ADgAWABNAGgAZABUAFQAbQBsAFcAbABUAGcAPQA9AHwAOABhADQAYQA0ADIAMQBkADQAZgA4AGEAYwA2ADUAMQA5AGYAOABjADIAOQBiAGMAZAA4AGQAMQA4ADgAMgA1AGEAYQA1ADgANgA0AGMAMQBlAGEAYQBhADgAMABmADMAMQAzADIAMgAwAGMANgBiAGIAZQBmADkAMwA1AGYAMAAxAGMAMwBiADEAZgA0AGUAZABkADcAZQA4AGQAMgBlADEAYQA4ADkAYQAyADcAYgA4ADYANwA2AGMAOQBhAGEAOAA3ADcAOQAxADMANwBiADEAOQA2AGIAOQBkAGIAMgA4ADkAZgBlADcAMgBiAGYANgA1ADMAMQA4ADkAZABmAGYAZAA1ADkAOQBhADYANAA3ADQAMwA5ADMAMwBlADMAYwA1ADgAYQA4AGEAZQBlADIANwA4ADkAMQAwAGUAYgAzAGYAZABkADIANQA2ADYAMQA3AGIAYQBkADgANABhADYAMwBkADMANAAxADUANQAwADEAZgA3ADcAZgAzAGEA"
                'marianne' = "76492d1116743f0423413b16050a5345MgB8AFQATgA2AHYAbQA4AHMAZQBpAHYASwBEAHgAMgByAHgALwBtAFkARwBwAGcAPQA9AHwAMAA0AGEAYQBlAGEANAA1ADEANgAxAGIANgA2ADIAMwA3AGQAYgBjADQAMQAzAGQAMQA0ADEAYQAxADgANgBmAGQAMgBiADQAYQA4ADMAOAA2ADEANAAxAGYAMwBkADEANQBhADUANQA5ADYAMABiADIAYwA3ADQAZQA4ADQAMwAyADkAZQA3AGEAZQAwADQAZgA0ADIAZAAzADkAMQAxADEAOAA5AGUAMwA0ADkAZQBjAGMANgBlADYAYwAyAGIAMgAzADkAMgBlADcANgA1AGUANQAxADgAZQAwAGYANQBiAGQAMwA4ADEANAA0ADgAMwA2ADUAZQA4ADcAMQAwADQAMAA2ADAAZgA5AGMAZABmADQAYQA5AGUANQBmAGIAMQA5AGYAZAAyADUAOAA3AGYAMwA3AGUAMAA4ADEAOQA0AGYANgA0ADMAMAAxADIAOQA0ADgAZgAzADAAOAA5ADAAYwBiAGMAZAAxAGUAOQA2AGEAYwBiADYAYQA5ADcA"
                'juliette' = "76492d1116743f0423413b16050a5345MgB8AFQAegA1AHYANQA2AFUAVAA4AEIAdgBxACsAaQA1AGwANABDAGwAVwAxAFEAPQA9AHwAOQA3AGIANQA3AGEAYwBhADUAOAAxADcAMAAwAGIAOAA5ADAAZABjADIAZQA2ADcAMgA0AGEAMgA2ADkAZABkADAANwAwAGUAZABlAGMAYgBkAGIAYgAxADIANABjADcAYQBkAGUAZQA0AGUAMABkAGIAZQBjADkAOAA2ADIANAA0ADQAZAA4AGEAZQA3AGEAMQA1ADEAMQBiADkAMAA5AGMANABlADAAYQBiADgAZQA5ADgAMgA4ADcAMwA5ADkAMgAzAGYAYQAyAGIAOAA5ADYAMAAxADcAMwAxADYAMQBiADgANgBiADkAZABmADgAMgBmAGIAYwBmADgANgA3ADEANQAzADQAZgAyAGEAOAA0AGUAZAA5ADkAMgA0ADAAZQBkAGYAYgAyADQAMgA4ADQAYQA2AGMAOAAyADEAMAA0ADYAZgAwADYAZAAyADAANABiADQAOQBlADAAYgBhAGMAZAA1AGYAYwAyADcANwA5AGEAZQBmAGMAYwA3AGEA"
                'alan' = "76492d1116743f0423413b16050a5345MgB8AFkAeQBLAGsAWAAzACsAbAA2ADgAWABNAGgAZABUAFQAbQBsAFcAbABUAGcAPQA9AHwAOABhADQAYQA0ADIAMQBkADQAZgA4AGEAYwA2ADUAMQA5AGYAOABjADIAOQBiAGMAZAA4AGQAMQA4ADgAMgA1AGEAYQA1ADgANgA0AGMAMQBlAGEAYQBhADgAMABmADMAMQAzADIAMgAwAGMANgBiAGIAZQBmADkAMwA1AGYAMAAxAGMAMwBiADEAZgA0AGUAZABkADcAZQA4AGQAMgBlADEAYQA4ADkAYQAyADcAYgA4ADYANwA2AGMAOQBhAGEAOAA3ADcAOQAxADMANwBiADEAOQA2AGIAOQBkAGIAMgA4ADkAZgBlADcAMgBiAGYANgA1ADMAMQA4ADkAZABmAGYAZAA1ADkAOQBhADYANAA3ADQAMwA5ADMAMwBlADMAYwA1ADgAYQA4AGEAZQBlADIANwA4ADkAMQAwAGUAYgAzAGYAZABkADIANQA2ADYAMQA3AGIAYQBkADgANABhADYAMwBkADMANAAxADUANQAwADEAZgA3ADcAZgAzAGEA"
                'gerard' = "76492d1116743f0423413b16050a5345MgB8AEUASwBoAHUAQgA1AG0AdQB1AE4AawBRAHYAMgAzAFMAcwA1AHMANwBmAEEAPQA9AHwAMwA4ADUAMgA2AGUAZQA5AGIAMQAwADgANQA4ADMAZAA0ADQAZAAyADgAMwAxADMAMQBmADIAOQAxAGUAYQAyADkANAAzAGIAZAA2ADIANgA2ADUAMQBlADgAMAA1AGIANwA2ADMAOABhADEANAA3ADgANgA1ADUAYwAxAGQANAA1ADEAOQBhADkAMABkADIAZABhAGYAYgA0ADYAMAA2ADUAOAA4AGEAZAA2AGEANQBkAGYANwAzAGIAYQA3AGYAOQA5ADEAOQBkAGEAZgBjADcAYwA3AGUAZgA1ADAAMQAyADUAMABjADcAZABiADIAOQA4ADMANgA4AGIAZgAxADgAOAAwADkAZQA0ADcANQA5ADUANgBhADQANwBkADIAYwA4ADEANAAyAGUAZgA0ADAAMgBiADgAMgBiAGMANwA0AGIANwAzADgAMQA4ADMAMwA2ADEAOQBlAGUANgA2AGUAZABlAGUANgBmAGYAMwBmADQAZQBlADkAZQAxADEA"
                'james' = "76492d1116743f0423413b16050a5345MgB8AEUASwBoAHUAQgA1AG0AdQB1AE4AawBRAHYAMgAzAFMAcwA1AHMANwBmAEEAPQA9AHwAMwA4ADUAMgA2AGUAZQA5AGIAMQAwADgANQA4ADMAZAA0ADQAZAAyADgAMwAxADMAMQBmADIAOQAxAGUAYQAyADkANAAzAGIAZAA2ADIANgA2ADUAMQBlADgAMAA1AGIANwA2ADMAOABhADEANAA3ADgANgA1ADUAYwAxAGQANAA1ADEAOQBhADkAMABkADIAZABhAGYAYgA0ADYAMAA2ADUAOAA4AGEAZAA2AGEANQBkAGYANwAzAGIAYQA3AGYAOQA5ADEAOQBkAGEAZgBjADcAYwA3AGUAZgA1ADAAMQAyADUAMABjADcAZABiADIAOQA4ADMANgA4AGIAZgAxADgAOAAwADkAZQA0ADcANQA5ADUANgBhADQANwBkADIAYwA4ADEANAAyAGUAZgA0ADAAMgBiADgAMgBiAGMANwA0AGIANwAzADgAMQA4ADMAMwA2ADEAOQBlAGUANgA2AGUAZABlAGUANgBmAGYAMwBmADQAZQBlADkAZQAxADEA"
            }
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value "[Interface]"
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value "Address = $($ipEquivalenceVPN[$username])"
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value "DNS = 10.100.0.1,10.100.0.1"
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value "PrivateKey = $(Decrypt -EncryptedString $encryptedPrivateKeys[$username] -EncryptionKey $Key)"
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value " "
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value "[Peer]"
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value "PublicKey = $(Decrypt -EncryptedString $encryptedPublicKeys[$username] -EncryptionKey $Key)"
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value "PresharedKey = $(Decrypt -EncryptedString $encryptedPreSharedKeys[$username] -EncryptionKey $Key)"
            Add-Content -Path "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf" -Value "AllowedIPs = 0.0.0.0/0,::/0"
            Write-Host "`r[✓] $($langmap.68)... Done !"
            # applyWireGuardConfig -configPath "$userDataDir\ServerDeploy\Ad-Blocking_only-DNS.conf" -interface "wg0"
            Write-Output "The configuration file was created successfully !"
            Write-Output "Please follow this link to view a tutorial on how to apply these configurations : LINK"
            Pause
            notepad.exe "$userDataDir\ServerDeploy\VPN\VPN-all-traffick.conf"
        }
    }
} elseif ($ReConfigure -eq $true) {
    Write-Output "Sussy Baka"
    Start-Sleep 5
}
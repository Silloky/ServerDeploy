param (
    [Parameter(Position = 0)]$path,
    [Parameter(Position = 1)]$csv,
    [Parameter(Position = 2)]$cache,
    [Parameter(Position = 2)]$lang
)
[system.Text.Encoding]::ASCII
$name = Split-Path -Path $path -Leaf
$cacheLoc = $cache + "\$name"
if ((Test-Path -Path $cache) -eq $false){
    New-Item -Path $cache -ItemType Directory
}
if ((Test-path -Path $csv) -eq $false){
    New-Item -Path $csv -ItemType File
    Add-Content -Path $csv -Value "cache,server"
}
if ($lang -eq "EN"){
    $langmap = @{
        1 = "Successfully added $name to offline-access list !"
        2 = "Your files will be available shortly"
        3 = "Couldn't add $name to offline-access list !"
        4 = "Folder is already being backed up !"
    }
} elseif ($lang -eq "FR") {
    $langmap = @{
        1 = "$name a bien ete ajoute a la liste d'acces hors-ligne !"
        2 = "Vos fichiers seront disponibles dans peu de temps"
        3 = "Nous n'avons pas pu ajouter $name a la liste d'acces hors-ligne !"
        4 = "Le dossier n'est pas synchronise !"
    }
}
if ((Test-Path -Path $cacheLoc) -eq $false){
    New-Item -Path $cacheLoc -ItemType Directory
    $outputLine = "$cacheLoc,$path"
    $outputLine | out-file $csv -Encoding ascii -Force -Append
    New-Item -Path $cacheLoc\file -ItemType File
    $image = New-BTImage -Source "$PSScriptRoot\icons\information.ico" -Crop None
    New-BurntToastNotification -Text "$($langmap.1)","$($langmap.2)" -AppLogo $image
} else {
    $image = New-BTImage -Source "$PSScriptRoot\icons\cross.ico" -Crop None
    New-BurntToastNotification -Text "$($langmap.3)","$($langmap.4)" -AppLogo $image
}
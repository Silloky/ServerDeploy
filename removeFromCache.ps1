param (
    [Parameter(Position = 0)]$path,
    [Parameter(Position = 1)]$csv,
    [Parameter(Position = 2)]$cache,
    [Parameter(Position = 3)]$lang
)

$name = Split-Path -Path $path -Leaf
$cacheLoc = $cache + "\$name"
if ($lang -eq "EN"){
    $langmap = @{
        1 = "Successfully removed $name from offline-access list !"
        2 = "Your files will be removed from your PC shortly."
        3 = "Couldn't remove $name from offline-access list..."
        4 = "Folder isn't being backed up !"
    }
} elseif ($lang -eq "FR"){
    $langmap = @{
        1 = "$name a bien été supprimé de la liste d'accès hors-ligne !"
        2 = "Vos fichiers seront supprimés de votre PC dans peu de temps."
        3 = "Nous n'avons pas pu supprimer $name de la liste d'accès hors-ligne..."
        4 = "Le dossier n'est pas synchronisé !"
    }
}
if ((Test-Path -Path $cacheLoc) -eq $true){
    $content = Select-String -Path $csv -Pattern "$name" -NotMatch | Select-Object -ExpandProperty Line
    Set-Content -Path $csv -Value $content
    Remove-Item -Path $cacheLoc -Recurse
    $image = New-BTImage -Source "$PSScriptRoot\icons\information.ico" -Crop None
    New-BurntToastNotification -Text "$($langmap.1)","$($langmap.2)" -AppLogo $image
} else {
    $image = New-BTImage -Source "$PSScriptRoot\icons\cross.ico" -Crop None
    New-BurntToastNotification -Text "$($langmap.3)","$($langmap.4)" -AppLogo $image
}
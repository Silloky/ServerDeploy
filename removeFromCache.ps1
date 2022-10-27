param (
    [Parameter(Position = 0)]$path,
    [Parameter(Position = 1)]$csv,
    [Parameter(Position = 2)]$cache
)
$name = Split-Path -Path $path -Leaf
$cacheLoc = $cache + "\$name"

if ((Test-Path -Path $cacheLoc) -eq $true){
    $content = Select-String -Path $csv -Pattern "$name" -NotMatch | Select-Object -ExpandProperty Line
    Set-Content -Path $csv -Value $content
    Remove-Item -Path $cacheLoc -Recurse
    $image = New-BTImage -Source "$PSScriptRoot\icons\information.ico" -Crop None
    New-BurntToastNotification -Text "Successfully removed $name from offline-access list !","Your files will be removed from your PC shortly." -AppLogo $image
} else {
    $image = New-BTImage -Source "$PSScriptRoot\icons\cross.ico" -Crop None
    New-BurntToastNotification -Text "Couldn't remove $name from offline-access list !","Folder isn't being backed up !" -AppLogo $image
}
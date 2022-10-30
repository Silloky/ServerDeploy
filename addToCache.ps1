param (
    [Parameter(Position = 0)]$path,
    [Parameter(Position = 1)]$csv,
    [Parameter(Position = 2)]$cache
)
$name = Split-Path -Path $path -Leaf
$cacheLoc = $cache + "\$name"
if ((Test-Path -Path $cache) -eq $false){
    New-Item -Path $cache -ItemType Directory
}
if ((Test-path -Path $csv) -eq $false){
    New-Item -Path $csv -ItemType File
}
if ((Test-Path -Path $cacheLoc) -eq $false){
    New-Item -Path $cacheLoc -ItemType Directory
    $outputLine = "$cacheLoc,$path"
    $outputLine | out-file $csv -Encoding ascii -Force -Append
    New-Item -Path $cacheLoc\file -ItemType File
    $image = New-BTImage -Source "$PSScriptRoot\icons\information.ico" -Crop None
    New-BurntToastNotification -Text "Successfully added $name to offline-access list !","Your files will be available shortly." -AppLogo $image
} else {
    $image = New-BTImage -Source "$PSScriptRoot\icons\cross.ico" -Crop None
    New-BurntToastNotification -Text "Couldn't add $name to offline-access list !","Folder is already being backed up !" -AppLogo $image
}







$progress = New-BTProgressBar -Title "Copying progress :" -Status "Downloading..." -Value 'value'
$image = New-BTImage -Source "$PSScriptRoot\icons\shell32_16739.ico" -Crop None
$button = New-BTButton -Dismiss -Content "OK"
$binding = @{
    value = 0
}
New-BurntToastNotification -Text "Downloading your files...", "Your files are being downloaded so they can be available offline." -DataBinding $binding -UniqueIdentifier "001" -ProgressBar $progress -AppLogo $image
Start-Sleep 3
foreach ($n in 1..100){
    Start-Sleep 0.5
    $binding['value'] = $binding['value'] + 0.02
    $null = Update-BTNotification -UniqueIdentifier "001" -DataBinding $binding
}
Remove-BTNotification -UniqueIdentifier "001"
New-BurntToastNotification -Text "Done !", "Your files are now available offline." -AppLogo $image -Button $button

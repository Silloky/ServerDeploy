$image = New-BTImage -Source "D:\Pictures\Profile image.png" -Crop Circle
$binding = @{
    text1 = "Downloading your files..."
    text2 = "Your files are being downloaded so they can be available offline."
    image = $image
    value = 0
    status = "Downloading..."
}
$progress = New-BTProgressBar -Status $binding['status'] -Value $binding['value'] -Verbose
New-BurntToastNotification -Text $binding['text1'], $binding['text2'] -AppLogo $binding['image'] -ProgressBar $progress -UniqueIdentifier "toast" -Verbose
$value = 0
foreach ($n in 1..100){
    $newbinding = @{
        value = ($value + 0.01)
        text1 = "hello"
    }
    Update-BTNotification -DataBinding $newbinding -Verbose -UniqueIdentifier "toast" 
    Start-Sleep 1
}

# $text2 = New-BTText -Content "You're $n% there"
# $binding = New-BTBinding -Children $text1, $text2 -AppLogoOverride $image
# $visual = New-BTVisual -BindingGeneric $binding
# $content = New-BTContent -Visual $visual

# -ProgressBar 'progress'


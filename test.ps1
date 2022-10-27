[xml]$xml = @"
    <toast launch="app-defined-string">
    <visual>
        <binding template="ToastGeneric">
            <text hint-maxLines="1">Adaptive Tiles Meeting</text>
            <text>Conf Room 2001 / Building 135</text>
            <text>10:00 AM - 10:30 AM</text>
        </binding>
    </visual>
    </toast>
"@

$ToastXml = New-Object Windows.Data.Xml.Dom.XmlDocument
$ToastXml.LoadXml($xml.OuterXml)
$AppID = '{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe'
$Notification = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($AppID)
$Notification.Show($ToastXml)  
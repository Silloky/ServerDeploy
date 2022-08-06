Dim Arg, folderLocation
Set Arg = WScript.Arguments
folderLocation = Arg(0)
Set objFSO = Createobject("Scripting.FileSystemObject")
Set oFolder = objFSO.GetFolder(folderLocation)
For Each oFile in oFolder.Files
    Dim WinScriptHost
    Set WinScriptHost = CreateObject("WScript.Shell")
    WinScriptHost.Run Chr(34) & oFolder & Chr(92) & oFile.Name & Chr(34), 0
    Set WinScriptHost = Nothing
Next


Set objFSO = Createobject("Scripting.FileSystemObject")
Set oFile = objFSO.GetFile(WScript.Arguments(0))
CreateObject("Wscript.Shell").Run """" & oFile & """", 0, False
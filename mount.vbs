Set objFSO = Createobject("Scripting.FileSystemObject")
Set oFolder = objFSO.GetFolder(WScript.Arguments(0))
For Each oFile in oFolder.Files
	Dim command
	command = oFolder & Chr(92) & oFile.Name
	CreateObject("Wscript.Shell").Run """" & command & """", 0, False
Next 


'SJIS $Workfile: diff.vbs $$Revision: 3 $$Date: 25/01/11 22:02 $
'$NoKeywords: $

'-----    PowerShellのCompare-Objectを実行するマクロ

Dim cmdstr,OriginalFile,TargetFile,strOutput

OriginalFile = Editor.GetSelectedString(0)
TargetFile =  Editor.ExpandParameter("$F")

if OriginalFile = "" then
	OriginalFile = Editor.FileOpenDialog(Editor.ExpandParameter("$D"),"*.txt")
end if

if OriginalFile = "" then
	Editor.ErrorMsg("比較元ファイル名を選択してください。")
else
	ActivateWinOutput()
	Editor.Down

	'Editor.TraceOut "----   PowerShellのCompare-Objectを実行するマクロ    ----- "
	'Editor.TraceOut "OriginalFile:" & OriginalFile
	'Editor.TraceOut "TargetFile:" & TargetFile

	cmdstr = "powershell.exe -Command ""diff -IncludeEqual""" &_
			" (Get-Content """ & OriginalFile &  """)" &_
			" (Get-Content """ & TargetFile & """)"
	 
	strOutput = Editor.ExecCommand(cmdstr,1)
	Editor.TraceOut strOutput
	'Editor.TraceOut "----   ここまで    -----"
	Editor.InfoMsg("比較を実行しました。【アウトプット】を参照ください")
end if

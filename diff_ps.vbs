'SJIS $Workfile: diff_ps.vbs $$Revision: 1 $$Date: 25/01/12 15:01 $
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
'	Editor.Down

	'Editor.TraceOut "----   PowerShellのCompare-Objectを実行するマクロ    ----- "
	'Editor.TraceOut "OriginalFile:" & OriginalFile
	'Editor.TraceOut "TargetFile:" & TargetFile

	cmdstr = "powershell.exe -File ""G:\cmd\ps\diff.ps1""" &_
				" -OriginalFile """ & OriginalFile &  """" &_
				" -TargetFile """ & TargetFile & """"

	strOutput = Editor.ExecCommand(cmdstr,1)
	Editor.TraceOut strOutput
	'Editor.TraceOut "----   ここまで    -----"
	Editor.InfoMsg("比較を実行しました。【アウトプット】を参照ください")
end if

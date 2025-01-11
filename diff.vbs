'SJIS $Workfile: diff.vbs $$Revision: 3 $$Date: 25/01/11 22:02 $
'$NoKeywords: $

'-----    PowerShell��Compare-Object�����s����}�N��

Dim cmdstr,OriginalFile,TargetFile,strOutput

OriginalFile = Editor.GetSelectedString(0)
TargetFile =  Editor.ExpandParameter("$F")

if OriginalFile = "" then
	OriginalFile = Editor.FileOpenDialog(Editor.ExpandParameter("$D"),"*.txt")
end if

if OriginalFile = "" then
	Editor.ErrorMsg("��r���t�@�C������I�����Ă��������B")
else
	ActivateWinOutput()
	Editor.Down

	'Editor.TraceOut "----   PowerShell��Compare-Object�����s����}�N��    ----- "
	'Editor.TraceOut "OriginalFile:" & OriginalFile
	'Editor.TraceOut "TargetFile:" & TargetFile

	cmdstr = "powershell.exe -Command ""diff -IncludeEqual""" &_
			" (Get-Content """ & OriginalFile &  """)" &_
			" (Get-Content """ & TargetFile & """)"
	 
	strOutput = Editor.ExecCommand(cmdstr,1)
	Editor.TraceOut strOutput
	'Editor.TraceOut "----   �����܂�    -----"
	Editor.InfoMsg("��r�����s���܂����B�y�A�E�g�v�b�g�z���Q�Ƃ�������")
end if

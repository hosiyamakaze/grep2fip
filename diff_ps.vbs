'SJIS $Workfile: diff_ps.vbs $$Revision: 1 $$Date: 25/01/12 15:01 $
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
'	Editor.Down

	'Editor.TraceOut "----   PowerShell��Compare-Object�����s����}�N��    ----- "
	'Editor.TraceOut "OriginalFile:" & OriginalFile
	'Editor.TraceOut "TargetFile:" & TargetFile

	cmdstr = "powershell.exe -File ""G:\cmd\ps\diff.ps1""" &_
				" -OriginalFile """ & OriginalFile &  """" &_
				" -TargetFile """ & TargetFile & """"

	strOutput = Editor.ExecCommand(cmdstr,1)
	Editor.TraceOut strOutput
	'Editor.TraceOut "----   �����܂�    -----"
	Editor.InfoMsg("��r�����s���܂����B�y�A�E�g�v�b�g�z���Q�Ƃ�������")
end if

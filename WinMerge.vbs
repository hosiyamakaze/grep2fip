'SJIS $Workfile: WinMerge.vbs $$Revision: 1 $$Date: 25/01/12 18:56 $
'$NoKeywords: $

'-----    WinMerge���N������}�N��

Dim cmdstr,OriginalFile,TargetFile

OriginalFile = Editor.GetSelectedString(0)
TargetFile =  Editor.ExpandParameter("$F")

if OriginalFile = "" then
	OriginalFile = Editor.FileOpenDialog(Editor.ExpandParameter("$D"),"*.txt")
end if

if OriginalFile = "" then
	Editor.ErrorMsg("��r���t�@�C������I�����Ă��������B")
else

	cmdstr = "WinMergeU" &_
			" """ & OriginalFile &  """" &_
			" """ & TargetFile & """"

'	ActivateWinOutput()
'	Editor.TraceOut "���L�����s���܂��B"
'	Editor.TraceOut cmdstr

	Editor.ExecCommand cmdstr,0 
end if

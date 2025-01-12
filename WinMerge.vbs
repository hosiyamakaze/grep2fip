'SJIS $Workfile: WinMerge.vbs $$Revision: 1 $$Date: 25/01/12 18:56 $
'$NoKeywords: $

'-----    WinMergeを起動するマクロ

Dim cmdstr,OriginalFile,TargetFile

OriginalFile = Editor.GetSelectedString(0)
TargetFile =  Editor.ExpandParameter("$F")

if OriginalFile = "" then
	OriginalFile = Editor.FileOpenDialog(Editor.ExpandParameter("$D"),"*.txt")
end if

if OriginalFile = "" then
	Editor.ErrorMsg("比較元ファイル名を選択してください。")
else

	cmdstr = "WinMergeU" &_
			" """ & OriginalFile &  """" &_
			" """ & TargetFile & """"

'	ActivateWinOutput()
'	Editor.TraceOut "下記を実行します。"
'	Editor.TraceOut cmdstr

	Editor.ExecCommand cmdstr,0 
end if

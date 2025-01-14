'SJIS $Workfile: feditor.vbs $$Revision: 2 $$Date: 25/01/14 16:46 $
'$NoKeywords: $

'-----    feditorを起動するマクロ(存在するfipファイルの場合)

' FileSystemObjectのインスタンスを作成
Set fso = CreateObject("Scripting.FileSystemObject")

Dim cmdstr,TargetFile,msgstr


	TargetFile =  Editor.GetSelectedString(0)

	if TargetFile = "" then
		TargetFile = Editor.ExpandParameter("$F")
	end if

	if Right(TargetFile, 4) <> ".fip" THEN
		TargetFile= ""
	elseif (NOT fso.FileExists(TargetFile)) then
		TargetFile= ""
	end if

	cmdstr = "feditor " & TargetFile 

	ans = 1
	msgstr = cmdstr & vbcr & "実行しますか?"
	ans = Editor.OkCancelBox(msgstr)
	if ans = 1 then
		Editor.ExecCommand cmdstr,0 
	end if

' クリーンアップ
Set fso = Nothing
'SJIS $Workfile: feditor.vbs $$Revision: 2 $$Date: 25/01/14 16:46 $
'$NoKeywords: $

'-----    feditor���N������}�N��(���݂���fip�t�@�C���̏ꍇ)

' FileSystemObject�̃C���X�^���X���쐬
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
	msgstr = cmdstr & vbcr & "���s���܂���?"
	ans = Editor.OkCancelBox(msgstr)
	if ans = 1 then
		Editor.ExecCommand cmdstr,0 
	end if

' �N���[���A�b�v
Set fso = Nothing
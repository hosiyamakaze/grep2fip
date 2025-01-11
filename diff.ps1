#SJIS $Workfile: diff.ps1 $$Revision: 1 $$Date: 25/01/11 17:27 $
#$NoKeywords: $

param (
    [string]$OriginalFile,
    [string]$TargetFile
)

if(-not $OriginalFile){$OriginalFile = Read-Host "OriginalFile"}
if(-not $TargetFile){$TargetFile = Read-Host "TargetFile"}

Compare-Object -IncludeEqual -ReferenceObject (Get-Content $OriginalFile)  -DifferenceObject (Get-Content $TargetFile)

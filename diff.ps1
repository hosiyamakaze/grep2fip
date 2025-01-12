#SJIS $Workfile: diff.ps1 $$Revision: 2 $$Date: 25/01/12 15:03 $
#$NoKeywords: $

param (
    [string]$OriginalFile,
    [string]$TargetFile
)

if(-not $OriginalFile){$OriginalFile = Read-Host "OriginalFile"}
if(-not $TargetFile){$TargetFile = Read-Host "TargetFile"}

$difdata = Compare-Object -IncludeEqual -ReferenceObject (Get-Content $OriginalFile)  -DifferenceObject (Get-Content $TargetFile)
Write-Host "SideIndicator","InputObject" -Separator `t
$difdata | ForEach-Object { Write-Host $_.SideIndicator, $_.InputObject -Separator `t}

#SJIS $Workfile: diff.ps1 $$Revision: 4 $$Date: 25/01/12 19:00 $
#$NoKeywords: $

param (
    [string]$OriginalFile,
    [string]$TargetFile
)

if(-not $OriginalFile){$OriginalFile = Read-Host "OriginalFile"}
if(-not $TargetFile){$TargetFile = Read-Host "TargetFile"}

$refdata=(Get-Content $OriginalFile)
$difdata=(Get-Content $TargetFile)
$diff = Compare-Object  -ReferenceObject $refdata  -DifferenceObject $difdata
Write-Host "Ref","Dif","SideIndicator","InputObject" -Separator `t
$diff | ForEach-Object {
    $file = if ($_.SideIndicator -eq '<=') { $refdata } else { $difdata }
    $lineref = $refdata.IndexOf($_.InputObject) + 1
    $linedif = $difdata.IndexOf($_.InputObject) + 1
    Write-Host $lineref,$linedif,$($_.SideIndicator),$($_.InputObject) -Separator `t
}

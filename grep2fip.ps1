#SJIS $Workfile: grep2fip.ps1 $$Revision: 18 $$Date: 25/01/15 12:52 $
#$NoKeywords: $
#
#�T�N���G�f�B�^��grep�������ʂ�Frieve Editor�Ŋ��p���邽�߁A�f�[�^���H����B
#grep�������ʃt�@�C���̓��p�X�Ebasename.fip�Ƃ��ďo�͂���B
#���ʏo�͌`��:�m�[�}���E�t�@�C�����A�ɑΉ��B���݂͕s�B

#split or match or replace Pattern
$PTNtagVal   = '\s+[[](?:SJIS|EUC)[]]:?\s*'
$PTNextpos   = '[.][a-zA-Z0-9]+[(]\d+[,]\d+[)]'
$PTNPosition = '[(]\d+[,]\d+[)]'
$PTNtosyo    = '(�w.*�x).*$'
$PTNpathSum  = '^��"(.*)"'

# ���ʏo�͌`��
enum outMode_t{
    Normal		#�m�[�}��
    Summary		#�t�@�C����
    other
}
$isOutMode = [outMode_t]::other

#grep�������ʃt�@�C�������R���\�[�������͂���
Write-Host -ForegroundColor green -NoNewline "grep�������ʃt�@�C����?"
$tarfl = read-host
#���̓t�@�C�������݂��邱�Ƃ��m�F����
if(-not (Test-Path -Path $tarfl)){
    Write-Host -ForegroundColor red -NoNewline "grep�������ʃt�@�C���������݂��܂���B�����𒆒f���܂��B"
    exit
}

#�o�͂�fip�t�@�C���������肷��
$fipfl = (get-item $tarfl).Directory.FullName+"\"+(get-item $tarfl).basename +".fip"
Write-Host -ForegroundColor Yellow -NoNewline "fip�t�@�C����:"
Write-Host $fipfl

#grep�������ʃt�@�C����ǂݍ���
$CardDataRAW = Get-Content -Path $tarfl

#-----    1.�J�[�h���𒲂ׂ�
Write-Host -ForegroundColor Cyan -NoNewline "�J�[�h�������W�v��..."
$CardDataRAW | ForEach-Object {
    #�������ʂ��J�[�h�̃\�[�X�ɕϊ�����
    if ($_.StartsWith("�t�H���_")) {
        $tarFolder = ($_ -split '\s+')[1] #�t�H���_�����擾
    }elseif($_.StartsWith($tarFolder)){
        $Cardnum ++
    }elseif($_.StartsWith("��`""+$tarFolder)){
        $CardnumSum ++
    }
} -Begin{
    $isOutMode = [outMode_t]::other
    set-Variable -Name tarFolder -Value null
    set-Variable -Name cardnum -Value 0
    set-Variable -Name cardnumSum -Value 0
    set-Variable -Name CardData -Value @()
    set-Variable -Name cardTitle -Value @()
    set-Variable -Name cardBody -Value @()
} -End{
    if(($Cardnum -gt 0 -and $CardnumSum -eq 0) -or ($Cardnum -eq 0 -and $CardnumSum -gt 0)){

        #���ʏo�͌`�����m�[�}��(Normal)�Ȃ�Y���s�݂̂ɂ���
        if($Cardnum -gt 0){
            $isOutMode = [outMode_t]::Normal
            $CardDataRAW | ForEach-Object {
                if ($_.StartsWith("�t�H���_")) {
                    $tarFolder = ($_ -split '\s+')[1] #�t�H���_�����擾
                }elseif($_.StartsWith($tarFolder)){
                     $CardData += $_
                }
            } -Begin{
                set-Variable -Name tarFolder -Value null
                set-Variable -Name labelnum -Value 0
            }
            $CardData = $CardData | Select-Object -Unique
            $Cardnum = $CardData.Count
        }

        #���ʏo�͌`�����t�@�C����(Summary)�Ȃ�^�C�g���Ɩ{���ɕ�����
        if($CardnumSum -gt 0){
            $isOutMode = [outMode_t]::Summary

            $CardDataRAW | ForEach-Object {
                if ($_.StartsWith("�t�H���_")) {
                    $tarFolder = ($_ -split '\s+')[1] #�t�H���_�����擾
                }elseif($_.StartsWith("��`"" + $tarFolder)){
                    $curTitle =  ($_  -replace $PTNpathSum, '$1(1,1)') + ":"
                    $cardTitle += $curTitle
                }elseif($_.StartsWith("�E(")){
                    $cardBody += "${curTitle}$_" 
                }
            } -Begin{
                set-Variable -Name tarFolder -Value null
                set-Variable -Name cardTitle -Value @()
                set-Variable -Name cardBody -Value @()
            }
            $CardData = $cardTitle | Select-Object -Unique
            $cardBody = $cardBody | Select-Object -Unique
            $Cardnum = $CardData.count
        }
        Write-Host -ForegroundColor Cyan "�ς�."
        Write-Host -ForegroundColor green "�J�[�h�͏d������菜���āA${Cardnum}������܂��B"

        #�o�̓t�@�C�������݂��Ȃ����Ƃ��m�F����
        if(Test-Path -Path $fipfl){
            Write-Host -ForegroundColor red -NoNewline "������fip�t�@�C�������݂��܂��B�X�V���܂���(y/n)?"
            $ans = Read-Host 
            if ($ans.ToUpper() -eq "Y"){
                Remove-Item -Path  $fipfl -Force
            }else{
                Write-Host -ForegroundColor red "�����𒆒f���܂��B"
                exit
            }
        }
    }elseif($Cardnum -gt 0 -and  $CardnumSum -gt 0 ){
        Write-Host -ForegroundColor red "���ʏo�͌`��:�m�[�}��${Cardnum}���A�t�@�C����${CardnumSum}���A���݂ł��܂���B�����𒆒f���܂��B"
        exit
    }else{
        Write-Host -ForegroundColor red "�J�[�h����0���ł����B�����𒆒f���܂��B"
        exit
    }
}

#fip�t�@�C���̃w�b�_�[�����o�͂���
Write-Host -ForegroundColor Cyan -NoNewline "[Global]�Z�N�V�����o�͒�..."
("[Global]",`
"Version=7",`
"Arrange=0",`
"ArrangeMode=2",`
"AutoScroll=1",`
"AutoZoom=0",`
"FullScreen=-1",`
"Exit=-1",`
"Zoom=-1",`
"X=0.179100006818771",`
"Y=0.481400012969971",`
"TargetCard=-1000",`
"SizeLimitation=0",`
"LinkLimitation=0",`
"DateLimitation=0",`
"SizeLimitation=100",`
"LinkLimitation=3",`
"LinkDirection=0",`
"LinkBackward=0",`
"LinkTarget=-1",`
"DateLimitation=0",`
"DateLimitationDateType=0",`
"DateLimitationType=0") -join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
Write-Host -ForegroundColor Cyan "�ς�."

#�J�[�h�����A�J�[�hID���o�͂���
Write-Host -ForegroundColor Cyan -NoNewline "[Card]�Z�N�V�����o�͒�..."
("[Card]",`
"CardID=-1",`
("Num=" + $Cardnum)) -join "`r`n"| Out-File -FilePath $fipfl -Append -Encoding default
for ($i = 0; $i -lt $Cardnum; $i++) {
        $i.ToString() + "=" + $i | Out-File -FilePath $fipfl -Append -Encoding default
}
Write-Host -ForegroundColor Cyan "�ς�."

#[Link]���o�͂���
Write-Host -ForegroundColor Cyan -NoNewline "[Link]�Z�N�V�����o�͒�..."
("[Link]",`
 "Num=0")-join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
Write-Host -ForegroundColor Cyan "�ς�."


#Label�𒊏o����
$labelValues = New-Object 'System.Collections.Generic.List[string]' # List���쐬
$CardData | ForEach-Object {
    $titleBaseName = (($_  -split $PTNextPos)[0] -split '\\')[-1]
    if($titleBaseName -match $PTNtosyo){
        #�}���������x������
        $labelTosyo = $matches[$matches.count-1]
        if(-not $labelValues.Contains($labelTosyo)){
            $labelValues.Add($labelTosyo)| Out-Null
        }
        #���҂����x������
        (($titleBaseName -replace '[()]') -split ($labelTosyo -replace '[()]') -split '�A') | ForEach-Object {
            if(-not $_.Equals('') -and -not $labelValues.Contains($_)){
                $labelValues.Add($_)| Out-Null
            }
        }
    }else{
        #�t�@�C���̃x�[�X�������x������
        if(-not $labelValues.Contains($titleBaseName)){
            $labelValues.Add($titleBaseName)| Out-Null
        }
    }
} -Begin{
    set-Variable -Name tarFolder -Value null
    set-Variable -Name labelnum -Value 0
}

#[Label]���o�͂���
Write-Host -ForegroundColor Cyan -NoNewline "[Label]�Z�N�V�����o�͒�..."
("[Label]",`
 ("Num=" + $labelValues.Count.ToString()) )-join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default

$labelnum=0
foreach($item in $labelValues){
    $labelColor = "Co" + (0xFF0000 + $labelnum % 0x100).ToString()
    if($item -match $PTNtosyo){
        $labelColor = "Co" + (0x00FF00 + $labelnum % 0x100).ToString()
    }
    $labelnum.ToString() + "=" + $labelColor + ",En1,Sh1,Hi0,Fo0,Si100,Na" +$item | Out-File -FilePath $fipfl -Append -Encoding default
    $labelnum ++
}
Write-Host -ForegroundColor Cyan "�ς�."

#[LinkLabel]���o�͂���
Write-Host -ForegroundColor Cyan -NoNewline "[LinkLabel]�Z�N�V�����o�͒�..."
("[LinkLabel]",`
"Num=0")-join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
Write-Host -ForegroundColor Cyan "�ς�."

#�J�[�h�f�[�^���o�͂���
Write-Host -ForegroundColor Cyan -NoNewline "[CardData]�Z�N�V�����o�͒�..."
"[CardData]"  | Out-File -FilePath $fipfl -Append -Encoding default
$CardData | ForEach-Object {
    #�������ʂ��J�[�h�f�[�^�ɕϊ�����
    #Label����
    $fipflInfo = ($_ -split $PTNtagVal)
    $title = ($fipflInfo[0] -split '\\')[-1]
    $titleBaseName = ($title -split $PTNextpos)[0]
    if($titleBaseName -match $PTNtosyo){
        #�}���������x������
        $labelTosyo = $matches[$matches.count-1]
        $labels = ($labelValues.IndexOf($labelTosyo) + 1).ToString()
        #���҂����x������
        (($titleBaseName -replace '[()]') -split ($labelTosyo -replace '[()]') -split '�A') | ForEach-Object {
            if(-not $_.Equals('')){
                $labels = $labels + ',' + ($labelValues.IndexOf($_) + 1).ToString()
            }
        }
    }else{
        #�t�@�C���̃x�[�X�������x������
        $labels = ($labelValues.IndexOf($titleBaseName) + 1).ToString()
    }

    #�^�C���X�^���v�𓾂�
    $entryPath = ($fipflInfo[0] -replace $PTNPosition)
    if(-not $entryPath.Equals($currPath)){
        $currPath = $entryPath
        if($currPath -and (Test-Path -Path  $currPath)){
            $dateCreated = (get-item $currPath).CreationTime
            $dateUpdated = (get-item $currPath).LastWriteTime
            $dateViewed = (get-item $currPath).LastAccessTime
        }else{
            $dateCreated = $currDate
            $dateUpdated = $currDate
            $dateViewed = $currDate
        }
    }

    #�J�[�h�f�[�^
    #----- �J�[�h�f�[�^�s��
    if($isOutMode -eq [outMode_t]::Summary){
        $cardLines = 15 + ($cardBody | Where-Object { $_.StartsWith("$($fipflInfo[0])")}).Count
        $title = "��" + $title -replace $PTNextpos
    }else{
        $cardLines = 15
    }

    ($cardLines, `
    ("Title:" + $title ),`
    ("Label:" + $labels),`
    "Fixed:0",`
    ("X:" + $posX.ToString()),`
    ("Y:" + $posY.ToString()),`
    "Size:100"  ,`
    "Shape:2"   ,`
    "Visible:1" ,`
    ("Created:" + $dateCreated.ToString("yyyy/MM/dd HH:mm:ss")) ,`
    ("Updated:" + $dateUpdated.ToString("yyyy/MM/dd HH:mm:ss")) ,`
    ("Viewed:"  + $dateViewed.ToString("yyyy/MM/dd HH:mm:ss")) ,`
    "-" ) -join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
    #-----�J�[�h�{��
    if($isOutMode -eq [outMode_t]::Summary){
        "��`"" + $fipflInfo[0] -replace $PTNPosition,"`""| Out-File -FilePath $fipfl -Append -Encoding default
        $tarptn = [regex]::Escape($fipflInfo[0])
        $cardBody | Where-Object { $_.StartsWith("$($fipflInfo[0])")}| ForEach-Object {
            $_ -replace "$tarptn" -replace $PTNtagVal | Out-File -FilePath $fipfl -Append -Encoding default
        }
    }else{
        "$($fipflInfo[1])" | Out-File -FilePath $fipfl -Append -Encoding default
    }
    #----- �Y���t�@�C��
    ("��",`
    "$($fipflInfo[0])") -join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
    $posX += 0.023 ; $posY += 0.1
} -Begin{
    set-Variable -Name tarFolder -Value null
    set-Variable -Name posX -Value 0.19
    set-Variable -Name posY -Value 0.22
    set-Variable -Name currDate -Value (Get-Date)
    set-Variable -Name currPath -Value null
}
Write-Host -ForegroundColor Cyan "�ς�."
Write-Host -ForegroundColor green "�I�����܂����B"


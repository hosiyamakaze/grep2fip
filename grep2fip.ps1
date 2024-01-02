#SJIS $Workfile: grep2fip.ps1 $$Revision: 6 $$Date: 24/01/01 15:11 $
#$NoKeywords: $
#
#サクラエディタのgrep検索結果をFrieve Editorで活用するため、データ加工する。
#grep検索結果ファイルの同パス・basename.fipとして出力する。
#

#grep検索結果ファイル名をコンソールより入力する
Write-Host -ForegroundColor green -NoNewline "grep検索結果ファイル名?"
$tarfl = read-host
#入力ファイルが存在することを確認する
if(-not (Test-Path -Path $tarfl)){
    Write-Host -ForegroundColor red -NoNewline "grep検索結果ファイル名が存在しません。処理を中断します。"
    exit
}

#出力のfipファイル名を決定する
$fipfl = (get-item $tarfl).Directory.FullName+"\"+(get-item $tarfl).basename +".fip"
Write-Host -ForegroundColor Yellow -NoNewline "fipファイル名:"
Write-Host $fipfl
$CardData = Get-Content -Path $tarfl

#-----    1.カード数を調べる
Write-Host -ForegroundColor Cyan -NoNewline "カード枚数を集計中..."
$CardData | ForEach-Object {
    #検索結果をカードのソースに変換する
    if ($_.StartsWith("フォルダ")) {
        $tarFolder = ($_ -split '\s+')[1] #フォルダ名を取得
    }elseif($_.StartsWith($tarFolder)){
        $Cardnum ++
    }
} -Begin{
    set-Variable -Name tarFolder -Value null
    set-Variable -Name cardnum -Value 0
} -End{
    Write-Host -ForegroundColor Cyan "済み."
    if($Cardnum -gt 0){
        #出力ファイルが存在しないことを確認する
        if(Test-Path -Path $fipfl){
            Write-Host -ForegroundColor red -NoNewline "同名のfipファイルが存在します。更新しますか(y/n)?"
            $ans = Read-Host 
            if ($ans.ToUpper() -eq "Y"){
                Remove-Item -Path  $fipfl -Force
            }else{
                Write-Host -ForegroundColor red "処理を中断します。"
                exit
            }
        }
    }else{
        Write-Host -ForegroundColor red "カード数は0枚でした。処理を中断します。"
        exit
    }
}

#fipファイルのヘッダー部を出力する
Write-Host -ForegroundColor Cyan -NoNewline "[Global]セクション出力中..."
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
Write-Host -ForegroundColor Cyan "済み."

#カード枚数、カードIDを出力する
Write-Host -ForegroundColor Cyan -NoNewline "[Card]セクション出力中..."
("[Card]",`
"CardID=-1",`
("Num=" + $Cardnum)) -join "`r`n"| Out-File -FilePath $fipfl -Append -Encoding default
$CardData | ForEach-Object {
    if ($_.StartsWith("フォルダ")) {
        $tarFolder = ($_ -split '\s+')[1] #フォルダ名を取得
    }elseif($_.StartsWith($tarFolder)){
        $Cardnum.ToString() + "=" + $Cardnum | Out-File -FilePath $fipfl -Append -Encoding default
        $Cardnum ++
    }
} -Begin{
    set-Variable -Name tarFolder -Value null
    set-Variable -Name cardnum -Value 0
} -End{
}

#[Link]～[LinkLabel]を出力する
("[Link]",`
"Num=0",`
"[Label]",`
"Num=3",`
"0=Co16711680,En1,Sh1,Hi0,Fo0,Si100,NaProblem",`
"1=Co65280,En1,Sh1,Hi0,Fo0,Si100,NaSolution",`
"2=Co255,En1,Sh1,Hi0,Fo0,Si100,NaResult",`
"[LinkLabel]",`
"Num=0")-join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
Write-Host -ForegroundColor Cyan "済み."

#カードデータを出力する
Write-Host -ForegroundColor Cyan -NoNewline "[CardData]セクション出力中..."
"[CardData]"  | Out-File -FilePath $fipfl -Append -Encoding default
$CardData | ForEach-Object {
    #検索結果をカードデータに変換する
    if ($_.StartsWith("フォルダ")) {
        $tarFolder = ($_ -split '\s+')[1] #フォルダ名を取得
    }elseif($_.StartsWith($tarFolder)){
        $fipflInfo = ($_ -split '\s+[[](?:SJIS|EUC)[]]:\s+')
       ("13",`
        ("Title: " + (($fipflInfo[0] -split '\\')[-1])),`
        "Fixed:0",`
        ("X:" + $posX.ToString()),`
        ("Y:" + $posY.ToString()),`
        "Size:100"  ,`
        "Shape:2"   ,`
        "Visible:1" ,`
        ("Created:" + $currDate.ToString("yyyy/MM/dd HH:mm:ss")) ,`
        ("Updated:" + $currDate.ToString("yyyy/MM/dd HH:mm:ss")) ,`
        ("Viewed:"  + $currDate.ToString("yyyy/MM/dd HH:mm:ss")) ,`
        "-" ,`
       "$($fipflInfo[0])" ,`
       "$($fipflInfo[1])") -join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
        $posX += 0.023 ; $posY += 0.1
    }
} -Begin{
    set-Variable -Name tarFolder -Value null
    set-Variable -Name posX -Value 0.19
    set-Variable -Name posY -Value 0.22
    set-Variable -Name currDate -Value (Get-Date)
} -End{
}
Write-Host -ForegroundColor Cyan "済み."
Write-Host -ForegroundColor green "終了しました。"

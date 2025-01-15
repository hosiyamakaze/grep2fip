#SJIS $Workfile: grep2fip.ps1 $$Revision: 18 $$Date: 25/01/15 12:52 $
#$NoKeywords: $
#
#サクラエディタのgrep検索結果をFrieve Editorで活用するため、データ加工する。
#grep検索結果ファイルの同パス・basename.fipとして出力する。
#結果出力形式:ノーマル・ファイル毎、に対応。混在は不可。

#split or match or replace Pattern
$PTNtagVal   = '\s+[[](?:SJIS|EUC)[]]:?\s*'
$PTNextpos   = '[.][a-zA-Z0-9]+[(]\d+[,]\d+[)]'
$PTNPosition = '[(]\d+[,]\d+[)]'
$PTNtosyo    = '(『.*』).*$'
$PTNpathSum  = '^■"(.*)"'

# 結果出力形式
enum outMode_t{
    Normal		#ノーマル
    Summary		#ファイル毎
    other
}
$isOutMode = [outMode_t]::other

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

#grep検索結果ファイルを読み込む
$CardDataRAW = Get-Content -Path $tarfl

#-----    1.カード数を調べる
Write-Host -ForegroundColor Cyan -NoNewline "カード枚数を集計中..."
$CardDataRAW | ForEach-Object {
    #検索結果をカードのソースに変換する
    if ($_.StartsWith("フォルダ")) {
        $tarFolder = ($_ -split '\s+')[1] #フォルダ名を取得
    }elseif($_.StartsWith($tarFolder)){
        $Cardnum ++
    }elseif($_.StartsWith("■`""+$tarFolder)){
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

        #結果出力形式がノーマル(Normal)なら該当行のみにする
        if($Cardnum -gt 0){
            $isOutMode = [outMode_t]::Normal
            $CardDataRAW | ForEach-Object {
                if ($_.StartsWith("フォルダ")) {
                    $tarFolder = ($_ -split '\s+')[1] #フォルダ名を取得
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

        #結果出力形式がファイル毎(Summary)ならタイトルと本文に分ける
        if($CardnumSum -gt 0){
            $isOutMode = [outMode_t]::Summary

            $CardDataRAW | ForEach-Object {
                if ($_.StartsWith("フォルダ")) {
                    $tarFolder = ($_ -split '\s+')[1] #フォルダ名を取得
                }elseif($_.StartsWith("■`"" + $tarFolder)){
                    $curTitle =  ($_  -replace $PTNpathSum, '$1(1,1)') + ":"
                    $cardTitle += $curTitle
                }elseif($_.StartsWith("・(")){
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
        Write-Host -ForegroundColor Cyan "済み."
        Write-Host -ForegroundColor green "カードは重複を取り除いて、${Cardnum}枚あります。"

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
    }elseif($Cardnum -gt 0 -and  $CardnumSum -gt 0 ){
        Write-Host -ForegroundColor red "結果出力形式:ノーマル${Cardnum}枚、ファイル毎${CardnumSum}枚、混在できません。処理を中断します。"
        exit
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
for ($i = 0; $i -lt $Cardnum; $i++) {
        $i.ToString() + "=" + $i | Out-File -FilePath $fipfl -Append -Encoding default
}
Write-Host -ForegroundColor Cyan "済み."

#[Link]を出力する
Write-Host -ForegroundColor Cyan -NoNewline "[Link]セクション出力中..."
("[Link]",`
 "Num=0")-join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
Write-Host -ForegroundColor Cyan "済み."


#Labelを抽出する
$labelValues = New-Object 'System.Collections.Generic.List[string]' # Listを作成
$CardData | ForEach-Object {
    $titleBaseName = (($_  -split $PTNextPos)[0] -split '\\')[-1]
    if($titleBaseName -match $PTNtosyo){
        #図書名をラベルする
        $labelTosyo = $matches[$matches.count-1]
        if(-not $labelValues.Contains($labelTosyo)){
            $labelValues.Add($labelTosyo)| Out-Null
        }
        #著者をラベルする
        (($titleBaseName -replace '[()]') -split ($labelTosyo -replace '[()]') -split '、') | ForEach-Object {
            if(-not $_.Equals('') -and -not $labelValues.Contains($_)){
                $labelValues.Add($_)| Out-Null
            }
        }
    }else{
        #ファイルのベース名をラベルする
        if(-not $labelValues.Contains($titleBaseName)){
            $labelValues.Add($titleBaseName)| Out-Null
        }
    }
} -Begin{
    set-Variable -Name tarFolder -Value null
    set-Variable -Name labelnum -Value 0
}

#[Label]を出力する
Write-Host -ForegroundColor Cyan -NoNewline "[Label]セクション出力中..."
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
Write-Host -ForegroundColor Cyan "済み."

#[LinkLabel]を出力する
Write-Host -ForegroundColor Cyan -NoNewline "[LinkLabel]セクション出力中..."
("[LinkLabel]",`
"Num=0")-join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
Write-Host -ForegroundColor Cyan "済み."

#カードデータを出力する
Write-Host -ForegroundColor Cyan -NoNewline "[CardData]セクション出力中..."
"[CardData]"  | Out-File -FilePath $fipfl -Append -Encoding default
$CardData | ForEach-Object {
    #検索結果をカードデータに変換する
    #Label得る
    $fipflInfo = ($_ -split $PTNtagVal)
    $title = ($fipflInfo[0] -split '\\')[-1]
    $titleBaseName = ($title -split $PTNextpos)[0]
    if($titleBaseName -match $PTNtosyo){
        #図書名をラベルする
        $labelTosyo = $matches[$matches.count-1]
        $labels = ($labelValues.IndexOf($labelTosyo) + 1).ToString()
        #著者をラベルする
        (($titleBaseName -replace '[()]') -split ($labelTosyo -replace '[()]') -split '、') | ForEach-Object {
            if(-not $_.Equals('')){
                $labels = $labels + ',' + ($labelValues.IndexOf($_) + 1).ToString()
            }
        }
    }else{
        #ファイルのベース名をラベルする
        $labels = ($labelValues.IndexOf($titleBaseName) + 1).ToString()
    }

    #タイムスタンプを得る
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

    #カードデータ
    #----- カードデータ行数
    if($isOutMode -eq [outMode_t]::Summary){
        $cardLines = 15 + ($cardBody | Where-Object { $_.StartsWith("$($fipflInfo[0])")}).Count
        $title = "■" + $title -replace $PTNextpos
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
    #-----カード本体
    if($isOutMode -eq [outMode_t]::Summary){
        "■`"" + $fipflInfo[0] -replace $PTNPosition,"`""| Out-File -FilePath $fipfl -Append -Encoding default
        $tarptn = [regex]::Escape($fipflInfo[0])
        $cardBody | Where-Object { $_.StartsWith("$($fipflInfo[0])")}| ForEach-Object {
            $_ -replace "$tarptn" -replace $PTNtagVal | Out-File -FilePath $fipfl -Append -Encoding default
        }
    }else{
        "$($fipflInfo[1])" | Out-File -FilePath $fipfl -Append -Encoding default
    }
    #----- 該当ファイル
    ("∞",`
    "$($fipflInfo[0])") -join "`r`n" | Out-File -FilePath $fipfl -Append -Encoding default
    $posX += 0.023 ; $posY += 0.1
} -Begin{
    set-Variable -Name tarFolder -Value null
    set-Variable -Name posX -Value 0.19
    set-Variable -Name posY -Value 0.22
    set-Variable -Name currDate -Value (Get-Date)
    set-Variable -Name currPath -Value null
}
Write-Host -ForegroundColor Cyan "済み."
Write-Host -ForegroundColor green "終了しました。"


#CyberCondor : 2022-11-6 through 2022-11-11

<#
.SYNOPSIS
Where are all my files? Where is all this data coming from? How many folders are in each folder in this current folder?
Stop searching for your data in the UI. Prepare for selective backups. Know where the majority of your data is the closer to root you search. 
.DESCRIPTION
Recursively correlate directory structures, file counts, directory counts, largest files, and total directory size.
.PARAMETER Dir
Specifies a directory other than the current working directory.
.PARAMETER Format
Specifies the format of file size calculated and displayed.
.EXAMPLE
PS C:\> Get-DirStats -Dir ~\ -Format GB
.EXAMPLE
PS C:\> Get-DirStats -Format KB
#>

param(
    [Parameter(Mandatory=$False, Position=0, ValueFromPipeline=$false)]
    [System.String]$Dir,

    [Parameter(Mandatory=$False, Position=0, ValueFromPipeline=$false)]
    [System.String]$Format
)

$CurrDir = (pwd).Path

if(($Dir) -and (Test-Path $Dir)){cd $Dir; $AllItemsInCurrDir = Get-Item ./*}
else{$AllItemsInCurrDir = Get-Item ./*}

$FormatAndPath = New-Object -TypeName PSObject -Property @{Path="$((pwd).Path)"}

if(($Format -eq "KB") -or ($Format -eq "GB") -or ($Format -eq "TB")){
    $FormatAndPath | Add-Member -NotePropertyMembers @{Format=$Format}
}
else{$FormatAndPath | Add-Member -NotePropertyMembers @{Format="MB"}}

$FormatAndPath | select Format,Path | fl

$Index = 0
$TotalIndex = ($AllItemsInCurrDir).count
foreach($ThisDir in $AllItemsInCurrDir){
    $Index++
    $ContentsOfThisDir = Get-ChildItem $ThisDir.Name -Recurse -Force -ErrorAction Ignore
    $ContentsCount     = ($ContentsOfThisDir).count
    $ContentsIndex     = 1
    $TotalDirCount     = 0
    $TotalFileCount    = 0
    $TotalLength       = 0
    $LargestItemSize   = 0
    $LargestItemDir    = $null
    foreach($Item in $ContentsOfThisDir){
        Write-Progress -id 1 -Activity "Collecting Stats for -> $($ThisDir.Name) ( $([int]$Index) / $($TotalIndex) )" -Status "$(($ContentsIndex++/$ContentsCount).ToString("P")) Complete"
        if($Item.Mode -like "d*"){
            $TotalDirCount++
        }
        elseif($Item.Mode -NotLike "d*"){
            $TotalFileCount++
        }
        if($Item.Length){
            $TotalLength += ($Item).Length
            if($LargestItemSize -lt ($Item).Length){
                $LargestItemSize = ($Item).Length
                $LargestItemDir  = $Item.VersionInfo.FileName
            }
        }
    }
    $ThisDir | Add-Member -NotePropertyMembers @{Contents=$ContentsOfThisDir}
    $ThisDir | Add-Member -NotePropertyMembers @{DirCount=$TotalDirCount}
    $ThisDir | Add-Member -NotePropertyMembers @{FileCount=$TotalFileCount}
    $ThisDir | Add-Member -NotePropertyMembers @{LargestItem=$LargestItemDir}
    if    ($Format -eq "KB"){$ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize=[math]::round($LargestItemSize/1KB, 8)} ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize=[math]::round($TotalLength/1KB, 8)}}
    elseif($Format -eq "MB"){$ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize=[math]::round($LargestItemSize/1MB, 8)} ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize=[math]::round($TotalLength/1MB, 8)}}
    elseif($Format -eq "GB"){$ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize=[math]::round($LargestItemSize/1GB, 8)} ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize=[math]::round($TotalLength/1GB, 8)}}
    elseif($Format -eq "TB"){$ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize=[math]::round($LargestItemSize/1TB, 8)} ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize=[math]::round($TotalLength/1TB, 8)}}
    else                    {$ThisDir | Add-Member -NotePropertyMembers @{LargestItemSize=[math]::round($LargestItemSize/1MB, 8)} ; $ThisDir | Add-Member -NotePropertyMembers @{TotalSize=[math]::round($TotalLength/1MB, 8)}} #Set to MB by default
}
Write-Progress -id 1 -Completed -Activity "Complete"
$AllItemsInCurrDir | select Mode,LastWriteTime,Name,DirCount,FileCount,TotalSize,LargestItemSize,LargestItem,Contents | sort TotalSize,FileCount,DirCount,Mode,Contents | ft

if($Dir){cd $CurrDir}

Write-Output "Complete!"

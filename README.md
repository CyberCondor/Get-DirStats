# Get-DirStats.ps1

Have you ever wondered what the biggest file inside of an entire directory structure is?
Have you ever stared at a folder in the CLI and wondered "How many folders are in this folder?"
You've inherited a bunch of directories, storage is full, and you have no idea where to start cleaning up or what files to compress first?
This script could help.

### SYNOPSIS
Where are all my files? Where is all this data coming from? How many folders are in each folder in this current folder?
Stop searching for your data in the UI. Prepare for selective backups. Know where the majority of your data is the closer to root you search. 
### DESCRIPTION
Recursively correlate directory structures, file counts, directory counts, largest files, and total directory size.
### SYNTAX
```Get-DirStats.ps1 [[-Dir] <String>] [[-Format] <String>] [<CommonParameters>]```
### PARAMETER Dir
Specifies a directory other than the current working directory.
### PARAMETER Format
Specifies the format of file size calculated and displayed. (KB, MB, GB, TB)
### EXAMPLE
PS C:\> ```Get-DirStats -Dir ~\ -Format GB```
### EXAMPLE
PS C:\> ```Get-DirStats -Format KB```

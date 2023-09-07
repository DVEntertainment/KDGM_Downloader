#SingleInstance Force

if not A_IsAdmin
	Run *RunAs "%A_ScriptFullPath%" ; (A_AhkPath is usually optional if the script has the .ahk extension.) You would typically check  first.


newfolder = %A_AppData%\KDGM Downloader v1

if(FileExist(newfolder)){
MSGBox, 4, , KDGM Downloader is already installed. Do you wish to reinstall?
IfMsgBox, No 
ExitApp
}

FileRemoveDir, %A_AppData%\KDGM Downloader v1, 1
FileDelete, %A_StartupCommon%\KDGM_downloader.lnk

InputBox, RSSLink , RSS-feed link, Vul hieronder de RSS link van jou kerkdienstgemist pagina in.`nZie github voor verdere instructies,,400,150,Locale
FileSelectFolder, destinationfolder ,, 3, Selecteer de map waar de uitzendingen bewaard moeten worden.
FileCreateDir, %A_AppData%\KDGM Downloader v1\
sleep, 100
FileCopy, %A_ScriptDir%\files\KDGM_downloader.exe, %A_AppData%\KDGM Downloader v1
sleep, 100
FileCreateShortcut, %A_AppData%\KDGM Downloader v1\KDGM_downloader.exe, %A_StartupCommon%\KDGM_downloader.lnk, %A_AppData%\KDGM Downloader v1
sleep, 100
FileCopyDir, %A_ScriptDir%\files\ffmpeg, %A_AppData%\KDGM Downloader v1\ffmpeg
sleep, 100
FileDelete, %A_AppData%\KDGM Downloader v1\Settings.txt
sleep, 100
FileAppend , %RSSLink% `n, %A_AppData%\KDGM Downloader v1\Settings.txt
sleep, 100
FileAppend , %destinationfolder%, %A_AppData%\KDGM Downloader v1\Settings.txt
sleep, 100
msgbox, KDGM Downloader is geinstalleerd en zal automatisch in de achtergrond werken.`nU kunt deze map nu verwijderen.`nOm instellingen te veranderen installeert u KDGM Downloader opnieuw.
Run, %A_StartupCommon%\KDGM_downloader.lnk

ExitApp

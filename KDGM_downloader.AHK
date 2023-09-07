#SingleInstance Force
/*
States:
0 running
1 downloading rssfeed
2 downloading videofile
3 checking video file
4 checking files that already existed before running
*/


;###READ INSTRUCTIONS###
state := 0
FileAppend, %A_NOW% starting software`n, log.txt
Loop, read, settings.txt
{
    if InStr(A_LoopReadLine, "")
		switch (A_index)
		{
		Case 1:
			rssfeed = %A_LoopReadLine%
		Case 2:
			DestinationFolder = %A_LoopReadLine%
		}
}

state := 1
FileAppend, %A_NOW% Downloading rssfeed`n, log.txt
UrlDownloadToFile, %rssfeed%, RSSwire.xml
state := 0
FileRead, xmldata, RSSwire.xml


;####SPLIT XML FILES####
FileAppend, %A_NOW% splitting xml files`n, log.txt
xmlfile:=ComObjCreate("MSXML2.DOMDocument.6.0")
xmlfile.async:=false
xmlfile.loadXML(xmldata)
title:="//rss/channel/item/title"
dates:="//rss/channel/item/pubDate"
link:="//rss/channel/item/enclosure/@url"
size:="//rss/channel/item/enclosure/@length"

;retreive names
	XMLnode:=xmlfile.selectNodes(title)
	If (XMLnode="")	;Check if node exists
	{
	  MsgBox,4112,Error,Node %title% not found ;tell user node doesnt exist and exit app
	  ExitApp
	}
	node := XMLnode.item(0) ; read first found node
	while node {
	   Title%A_index%:=node.text	;save container
	   filesfound := A_index		;update amount of nodes found to accomodate large or small archives
	   node := XMLnode.nextNode	;go to next node
	}

;retreive dates
	XMLnode:=xmlfile.selectNodes(dates)
	If (XMLnode="")
	{
	  MsgBox,4112,Error,Node %title% not found
	  ExitApp
	}
	node := XMLnode.item(0) ; 2nd item
	while node {
	   date%A_index%:=node.text
	   node := XMLnode.nextNode
	}

;retreive links
	XMLnode:=xmlfile.selectNodes(link)
	If (XMLnode="")
	{
	  MsgBox,4112,Error,Node %title% not found
	  ExitApp
	}
	node := XMLnode.item(0) ; 3rd item
	while node {
	   link%A_index%:=node.text
	   node := XMLnode.nextNode
	}



FileAppend, %A_NOW% looping files in destination folder`n, log.txt
FileList := ""
Loop, Files, %DestinationFolder%*.mp4	;check for all .mp4 files in downloadfolder
	FileList .= A_LoopFileName "`n"		;Save all filenames in var


loop %filesfound% {
		dFilename := date%A_index% " " Title%A_index% ;create filename that windows can handle based on info from XML
		dFilename := StrReplace(dFilename, ":")
	dateexist := InStr(FileList, dFilename)			  ;check if file exists in folder
	if(dateexist = 0){
		State = 4
		download(Title%A_index%, date%A_index%, link%A_index%, size%A_index%, dFileName, DestinationFolder)
		}
		else{
			FileAppend, %A_NOW% File is already downloaded`n, log.txt
		}
		
	}

;###CHECK INTEGRETY OF EXISTING FILES IN CASE OF SHUTDOWN###
FileAppend, %A_NOW% checking integrity of existing files`n, log.txt

FileList := ""
Loop, Files, %DestinationFolder%*.mp4	;check for all .mp4 files in downloadfolder
	FileList .= A_LoopFileName "`n"		;Save all filenames in var


loop %filesfound% {
		dFilename := date%A_index% " " Title%A_index% ;create filename that windows can handle based on info from XML
		dFilename := StrReplace(dFilename, ":")
	
	state := 3
		destination = %DestinationFolder%\%dFileName%.mp4
		sleep, 100
		path = "%DestinationFolder%%dFileName%.mp4"
		runwait, %A_ScriptDir%\ffmpeg\bin\checkfile.bat %path%, %A_ScriptDir%\ffmpeg\bin\ , hide
		temppath = % A_ScriptDir "\ffmpeg\bin\error.log"
		file := FileOpen(temppath, "r-d")
		FileSize := File.Length
		File.Close()
		sleep, 100
		FileDelete, %temppath%

		if(FileSize != 0){
		tpath = %DestinationFolder%\%dFileName%.mp4
		FileDelete, %tpath%
		FileAppend, ####ERROR IN EXISTING FILE####`n, log.txt
		FileAppend, date: %A_NOW%`n, log.txt
		FileAppend, File: %path%`n, log.txt
		FileAppend, ########`n, log.txt
		FileAppend, %A_NOW% ####ERROR IN EXISTING FILE####`n, errorlog.txt
		FileAppend, %A_NOW% File: %path%`n, errorlog.txt
		FileAppend, %A_NOW% ########`n, errorlog.txt
		reload
		}
		else{
		FileAppend, %A_NOW% No errors found in file %A_index%`n, log.txt
		}
		FileDelete, %A_ScriptDir%\ffmpeg\bin\error.log
	state := 0
	}

FileAppend, %A_NOW% ExitApp`n, log.txt

ExitApp


;#####DOWNLOAD FUNCTION#####

download(name, date, link, size, dFileName, DestinationFolder)
	{		
		destination = %DestinationFolder%\%dFileName%.mp4
		state := 2
		
		FileAppend, %A_NOW% downloading %link%`n, log.txt
		UrlDownloadToFile, %link%, %destination% ;rssfeed should be link
		FileAppend, %A_NOW% Downloading done`n, log.txt
		state := 0
		
		
	;$$$$$$CHECK INTEGRITY OF FILE USING FFMPEG$$$$$$
		state := 3
		FileAppend, %A_NOW% Checking integrity of file`n, log.txt
		path = "%destination%"
		runwait, %A_ScriptDir%\ffmpeg\bin\checkfile.bat %path%, %A_ScriptDir%\ffmpeg\bin\ , hide
		temppath = % A_ScriptDir "\ffmpeg\bin\error.log"
		file := FileOpen(temppath, "r-d")
		FileSize := File.Length
		File.Close()
		sleep, 100
		FileDelete, %temppath%
		if(FileSize != 0){
		tpath = %DestinationFolder%%dFileName%.mp4
		FileDelete, %tpath%
		FileAppend, %A_NOW% ####ERROR IN FILE####`n, errorlog.txt
		FileAppend, %A_NOW% File: %path%`n, errorlog.txt
		FileAppend, %A_NOW% ########`n, errorlog.txt
		FileAppend, %A_NOW% ####ERROR IN FILE####`n, log.txt
		FileAppend, %A_NOW% File: %path%`n, log.txt
		FileAppend, %A_NOW% ########`n, log.txt
		reload
		}
		else{
		FileAppend, %A_NOW% File is allright`n, log.txt
		}
		FileDelete, %A_ScriptDir%\ffmpeg\bin\error.log
		state := 0
		
	}

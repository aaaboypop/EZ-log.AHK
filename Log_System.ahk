LoadLogSetting(FilePath:="", ExitOnClose:=0, DirectSetting:=""){
	global LogProfile, Logs, LogGuiClose
	LogGuiClose := ExitOnClose

	If (DirectSetting=""){
		SplitPath, FilePath ,, FilePathDir
		SettingPath = %FilePath%

		If (!FileExist(SettingPath) or FilePath=""){
			DefaultSetting =
			(LTrim
				[_GuiSetting]
				x=0
				y=0

				[User]
				_LogLimit=999
				_WriteFile=False
				_AddGUI=True
				_AddProgress=PG1 PG2
				User=1

				[TestArea]
				_LogLimit=999
				_WriteFile=False
				_AddGUI=True
				_AddProgress=PG3
				Test=1
			)
			LogAppend(DefaultSetting, SettingPath)
		}
		FileRead, Setting, %SettingPath%
	}
	Else{
		Setting := DirectSetting
	}

	


	Logs:={}
	LogProfile := {}
	LogProfile.List := []
	LogProfile._GuiSetting := {}
	LogProfile.FilePath := FilePath
	Loop, Parse, Setting, `n, `r
	{
		i := A_index
		If RegExMatch(A_LoopField, "O)^\[(.*)\]$" , ObjMatch) ; Find ProfileName > Set Default value
		{
			ProfileName := ObjMatch.Value(1)
			If !(LogProfile.HasKey(ProfileName))
				LogProfile[ProfileName] := {}
			Logs[ProfileName] := []
			If !(ProfileName = "_GuiSetting")
				LogProfile.List.Push(ProfileName)
			LogProfile[ProfileName]._LogLimit := 19
			LogProfile[ProfileName]._WriteFile := "False"
			LogProfile[ProfileName]._AddGUI := "True"
			Continue
		}
		If RegExMatch(A_LoopField, "O)^(.*)=(.*)$" , ObjMatch)
		{
			KEY := ObjMatch.Value(1)
			Value := ObjMatch.Value(2)
			LogProfile[ProfileName][KEY] := Value
			If (LogProfile[ProfileName]._WriteFile = "True")
				FileCreateDir, %FilePathDir%\Logs
		}
	}
	If 	((LogProfile._GuiSetting.x = "") or (LogProfile._GuiSetting.y = "")){
		LogProfile._GuiSetting.x := LogProfile._GuiSetting.y := 0

	}		
}

LogRAdd(FunctionName, LogLvArray, LogAray){
	global LogProfile, Logs

	for a, LogLV in LogLvArray{
		for i,ProfileName in LogProfile.List{
			LogProfileLV := LogProfile[ProfileName][FunctionName]
			If (LogLV = LogProfileLV){
				For i, Text in LogAray{
					Logs[ProfileName].Push(Text)

					While(Logs[ProfileName].Length() >= LogProfile[ProfileName]._LogLimit){
						Logs[ProfileName].RemoveAt(1)
						LVDel_FirstRow(ProfileName)
					}
					
					If(LogProfile[ProfileName]._WriteFile = "True"){
						LogWrite(ProfileName, Text)
					}
					If(LogProfile[ProfileName]._AddGUI = "True"){
						AddGuiLog(ProfileName, FunctionName ,Text)
					}
				}
			}
		}		
	}
}

LogAdd(FunctionName, LogLvArray, Text){
	global LogProfile, Logs

	for a, LogLV in LogLvArray{
		for i,ProfileName in LogProfile.List{
			LogProfileLV := LogProfile[ProfileName][FunctionName]
			
			If (LogLV = LogProfileLV){
				Logs[ProfileName].Push(Text)

				While(Logs[ProfileName].Length() >= LogProfile[ProfileName]._LogLimit){
					Logs[ProfileName].RemoveAt(1)
					LVDel_FirstRow(ProfileName)
				}
				
				If(LogProfile[ProfileName]._WriteFile = "True"){
					LogWrite(ProfileName, Text)
				}
				If(LogProfile[ProfileName]._AddGUI = "True"){
					AddGuiLog(ProfileName, FunctionName ,Text)
				}
			}
		}	
	}
}

LogWrite(ProfileName, Text, TimeStamp:=True){
	If (TimeStamp){
		FormatTime, ts , YYYYMMDDHH24MISS, HH:mm:ss
		ts := ts " : "	
	}
	LogAppend(ts Text "`n", A_ScriptDir "\logs\Log_" ProfileName ".log")
}

AddGuiLog(ProfileName, FunctionName ,Text, TimeStamp:=True){
	global LogGUI
	If (TimeStamp){
		FormatTime, ts , YYYYMMDDHH24MISS, HH:mm:ss
	}

	;Save Last
	Last_DefaultGui := A_DefaultGui 
	Last_DefaultListView := A_DefaultListView
	;Set Default to LogGUI
	Gui, %LogGUI%:Default 
	Gui, %LogGUI%:ListView, GuiLV_%ProfileName%	
	LV_Add("", ts, FunctionName, Text)
	; Set Default Back
	Gui, %Last_DefaultGui%:Default 
	Gui, %Last_DefaultGui%:ListView, %Last_DefaultListView%	
}

LVDel_FirstRow(ProfileName){
	global LogGUI
	;Save Last
	Last_DefaultGui := A_DefaultGui 
	Last_DefaultListView := A_DefaultListView
	;Set Default to LogGUI
	Gui, %LogGUI%:Default 
	Gui, %LogGUI%:ListView, GuiLV_%ProfileName%	
	LV_Delete(1) ; Delete First Row
	; Set Default Back
	Gui, %Last_DefaultGui%:Default 
	Gui, %Last_DefaultGui%:ListView, %Last_DefaultListView%	
}

CreateLogGUI(){
	global

	ProgressBar := {}
	ProgressBar.HwndPB := {}
	ProgressBar.HwndText := {}
	ProgressBar.Index := []
	for i,v in LogProfile.List{
		Group_Tab_Name .= v "|"
	}
	Gui, New, +HwndLogGUI
	Gui, %LogGUI%:Add, Tab3,vLogGUITabControl, %Group_Tab_Name%
	for i,v in LogProfile.List{
		Gui, %LogGUI%:Tab, %v%
		Gui, %LogGUI%:Add, ListView, r20 w710 vGuiLV_%v% hwndhwndLV_%v% , Time|Func|Detail
		fn := Func("LogToClip").Bind()
		hwndlv := hwndLV_%v%
		GuiControl, +g, %hwndlv% , %fn%
		LV_ModifyCol(1, 80)
		LV_ModifyCol(2, 120)
		LV_ModifyCol(3, 500)
		_Add_PG := LogProfile[v]._AddProgress
		Loop, Parse, _Add_PG, %A_Space%
		{
			if(A_LoopField =""){
				Continue
			}
			Gui, %LogGUI%:Add, Progress, x22 y+10 w710 h19 border +c00dd00 hwndPGBHwnd, 0
			Gui, %LogGUI%:Add, Text, x27 y+-16 w240 +BackgroundTrans, %A_LoopField%
			Gui, %LogGUI%:Add, Text, x12 y+-13 w700 +BackgroundTrans Center hwndTextPercent, % A_Tab "0`%"
			if !(ProgressBar.HwndPB.HasKey(A_LoopField)){
				ProgressBar.HwndPB[A_LoopField] := []
				ProgressBar.HwndText[A_LoopField] := []
				ProgressBar.Index.Push(A_LoopField)
			}
			ProgressBar.HwndPB[A_LoopField].push(PGBHwnd)
			ProgressBar.HwndText[A_LoopField].push(TextPercent)
		}
	}
	GuiX := LogProfile._GuiSetting.x
	GuiY := LogProfile._GuiSetting.y
	Gui, %LogGUI%:Show, x%GuiX% y%GuiY% , AHK - LOG
	Gui, 1:New
}

LogToClip(){
	global LogGUI
	;Save Last
	Last_DefaultGui := A_DefaultGui 
	Last_DefaultListView := A_DefaultListView
	;Set Default to LogGUI
	Gui, %LogGUI%:Default 
	Gui, %LogGUI%:ListView, %A_GuiControl%

	if (A_GuiEvent = "DoubleClick")
	{
		LV_GetText(RowText, A_EventInfo, 3)
		If (A_EventInfo > 0)
		{
			Clipboard := RowText
		}
	}	
	; Set Default Back
	Gui, %Last_DefaultGui%:Default 
	Gui, %Last_DefaultGui%:ListView, %Last_DefaultListView%	
}

LogPG(Name, Percent){
	global ProgressBar
	for i,PGNAME in ProgressBar.Index
	{
		if (Name = PGNAME)
		{
			for i,HwndPG in ProgressBar.HwndPB[PGNAME]
			{
				GuiControl, , %HwndPG% , % Floor(Percent)
			}
			for i,HwndTX in ProgressBar.HwndText[PGNAME]
			{
				GuiControl, , %HwndTX% , % A_Tab Round(Percent, 2) " `%"
			}
		}
	}
}

LogGUIGuiClose(LogGUI){
	global LogGuiClose, LogProfile
	If (LogGuiClose){
		WinGetPos, X, Y, , , ahk_id %LogGUI%
		Filename := LogProfile.FilePath
		If ((x>=0) and (y>=0)){
			IniWrite, %X%, %Filename%, _GuiSetting, x
			IniWrite, %Y%, %Filename%, _GuiSetting, y			
		}
		ExitApp		
	}
	Else
		Gui, %LogGUI%:Hide
}

LogAppend(text, path){
	f := FileOpen(path, "a")
    f.Write(text)
	f.Close()
}

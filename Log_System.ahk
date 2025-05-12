LoadLogSetting(FilePath:="", ExitOnClose:=0, DirectSetting:="",StartHideGUI:=0, LogFileDir:=""){
	global LogProfile, Logs, LogGuiClose, LogFilePath, HideGUI
	HideGUI := StartHideGUI
	LogGuiClose := ExitOnClose

	If (DirectSetting=""){
		SplitPath, FilePath ,, FilePathDir
		SettingPath = %FilePath%

		If (!FileExist(SettingPath) or FilePath=""){
			DefaultSetting =
			( LTrim
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
			FileAppend, %DefaultSetting%, %SettingPath%
		}
		FileRead, Setting, %SettingPath%
	}
	Else{
		Setting := RemoveEmptyLines(DirectSetting)
	}

	LogPrefix := "Log_"
	LogFileDir := (LogFileDir="")? (A_ScriptDir "\logs") : (LogFileDir)


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
			If (LogProfile[ProfileName]._WriteFile = "True"){
					FileCreateDir, %LogFileDir%
			}
		}
	}
	If 	((LogProfile._GuiSetting.x = "") or (LogProfile._GuiSetting.y = "")){
		LogProfile._GuiSetting.x := LogProfile._GuiSetting.y := 0
	}
	LogFilePath := LogFileDir "\" LogPrefix
}

LogRAdd(Namespace, LogLvArray, LogAray){
	global LogProfile, Logs

	for a, LogLV in LogLvArray{
		for i,ProfileName in LogProfile.List{
			LogProfileLV := LogProfile[ProfileName][Namespace]
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
						AddGuiLog(ProfileName, Namespace ,Text)
					}
				}
			}
		}		
	}
}

LogAdd(Namespace, LogLvArray, Text){
	global LogProfile, Logs

	for a, LogLV in LogLvArray{
		for i,ProfileName in LogProfile.List{
			LogProfileLV := LogProfile[ProfileName][Namespace]
			
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
					AddGuiLog(ProfileName, Namespace ,Text)
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
	FileAppend, % ts Text "`n", %LogFilePath%%ProfileName%.log
}

LogGuiHide(){
	global LogGUI
	Gui, %LogGUI%:Hide
}
LogGuiShow(){
	global LogGUI
	Gui, %LogGUI%:Show
}

AddGuiLog(ProfileName, Namespace ,Text, TimeStamp:=True){
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
	LV_Add("", ts, Namespace, Text)
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
	events := new EventHook(LogGUI, controls, LogGuiClose)
	Gui, %LogGUI%:Add, Tab3,vLogGUITabControl, %Group_Tab_Name%
	for i,v in LogProfile.List{
		Gui, %LogGUI%:Tab, %v%
		Gui, %LogGUI%:Add, ListView, r20 w710 vGuiLV_%v% hwndhwndLV_%v% , Time|Name|Detail
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
	if (!HideGUI){
		Gui, %LogGUI%:Show, x%GuiX% y%GuiY% , AHK - LOG
	}
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


class EventHook
{
	__New(hGui, controls, ExitOnClose) {
		this.ExitOnClose := ExitOnClose
    	this.hGui := hGui
		this.controls := controls
		this.OnResize := ObjBindMethod(this, "WM_SIZE")
		this.OnSysCommand := ObjBindMethod(this, "WM_SYSCOMMAND")
		OnMessage(0x5, this.OnResize)
		OnMessage(0x112, this.OnSysCommand)
	}
	
	WM_SIZE(wp, lp) {
		static SIZE_MINIMIZED := 1
		if (A_Gui == this.hGui && wp = SIZE_MINIMIZED){
			WinHide, % "ahk_id " this.hGui
		}
	}

	WM_SYSCOMMAND(wp, lp) {
		static SC_CLOSE := 0xF060
		if (A_Gui != this.hGui)
			Return
		
		if (wp = SC_CLOSE) {
			If (this.ExitOnClose){
				MsgBox, 4, % " ", Do you want to Exit App?
				IfMsgBox, No
					Return 1
				
				this.Clear()
				ExitApp
			}
			Else{
				MsgBox, 4, % " ", Do you want to hide the window?
				IfMsgBox, No
					Return 1
				
				Gui, %A_Gui%: Hide
			}
		}
	}
	
	Clear() {
		OnMessage(0x112, this.OnSysCommand, 0)
		this.OnSysCommand := ""
		this.Clear := ""
	}
}

RemoveEmptyLines(str) {
    out := ""
    Loop, Parse, str, `n, `r
    {
        line := A_LoopField
        if !RegExMatch(line, "^\s*$") {
            line := LTrim(line)
            out .= line "`n"
        }
    }
    return RTrim(out, "`n")
}

class LogSystem{
	__New(FilePath:="", ExitOnClose:=0, DirectSetting:="", CreateGUI:=True){
		This.ExitOnClose := ExitOnClose
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
					_AddProgress=PG1
					User=1

					[CMD]
					_LogLimit=999
					_WriteFile=False
					_AddGUI=True
					_AddProgress=PG2
					Test=1
				)
				This.LogAppend(DefaultSetting, SettingPath)
			}
			FileRead, Setting, %SettingPath%
		}
		Else{
			Setting := LTrim(DirectSetting)
		}

		This.Logs:={}
		This.LogProfile := {}
		This.LogProfile.List := []
		This.LogProfile._GuiSetting := {}
		This.LogProfile.FilePath := FilePath
		Loop, Parse, Setting, `n, `r
		{
			i := A_index
			If RegExMatch(A_LoopField, "O)^\[(.*)\]$" , ObjMatch) ; Find ProfileName > Set Default value
			{
				ProfileName := ObjMatch.Value(1)
				If !(This.LogProfile.HasKey(ProfileName))
					This.LogProfile[ProfileName] := {}
				This.Logs[ProfileName] := []
				If !(ProfileName = "_GuiSetting")
					This.LogProfile.List.Push(ProfileName)
				This.LogProfile[ProfileName]._LogLimit := 19
				This.LogProfile[ProfileName]._WriteFile := "False"
				This.LogProfile[ProfileName]._AddGUI := "True"
				Continue
			}
			If RegExMatch(A_LoopField, "O)^(.*)=(.*)$" , ObjMatch)
			{
				KEY := ObjMatch.Value(1)
				Value := ObjMatch.Value(2)
				This.LogProfile[ProfileName][KEY] := Value
				If (This.LogProfile[ProfileName]._WriteFile = "True")
					FileCreateDir, %FilePathDir%\Logs
			}
		}
		If 	((This.LogProfile._GuiSetting.x = "") or (This.LogProfile._GuiSetting.y = "")){
			This.LogProfile._GuiSetting.x := This.LogProfile._GuiSetting.y := 0

		}	
		If (CreateGUI)
			This.CreateLogGUI()
	}

	LogRAdd(FunctionName, LogLvArray, LogAray){
		for a, LogLV in LogLvArray{
			for i,ProfileName in This.LogProfile.List{
				LogProfileLV := This.LogProfile[ProfileName][FunctionName]
				If (LogLV = LogProfileLV){
					For i, Text in LogAray{
						This.Logs[ProfileName].Push(Text)

						While(This.Logs[ProfileName].Length() >= This.LogProfile[ProfileName]._LogLimit){
							This.Logs[ProfileName].RemoveAt(1)
							This.LVDel_FirstRow(ProfileName)
						}
						
						If(This.LogProfile[ProfileName]._WriteFile = "True"){
							This.LogWrite(ProfileName, Text)
						}
						If(This.LogProfile[ProfileName]._AddGUI = "True"){
							This.AddGuiLog(ProfileName, FunctionName ,Text)
						}
					}
				}
			}		
		}
	}

	LogAdd(FunctionName, LogLvArray, Text){
		for a, LogLV in LogLvArray{
			for i,ProfileName in This.LogProfile.List{
				LogProfileLV := This.LogProfile[ProfileName][FunctionName]
				
				If (LogLV = LogProfileLV){
					This.Logs[ProfileName].Push(Text)

					While(This.Logs[ProfileName].Length() >= This.LogProfile[ProfileName]._LogLimit){
						This.Logs[ProfileName].RemoveAt(1)
						This.LVDel_FirstRow(ProfileName)
					}
					
					If(This.LogProfile[ProfileName]._WriteFile = "True"){
						This.LogWrite(ProfileName, Text)
					}
					If(This.LogProfile[ProfileName]._AddGUI = "True"){
						This.AddGuiLog(ProfileName, FunctionName ,Text)
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
		This.LogAppend(ts Text "`n", A_ScriptDir "\logs\Log_" ProfileName ".log")
	}

	AddGuiLog(ProfileName, FunctionName ,Text, TimeStamp:=True){
		LogGUI := This.LogGUI
		If (TimeStamp){
			FormatTime, ts , YYYYMMDDHH24MISS, HH:mm:ss
		}

		;Save Last
		Last_DefaultGui := A_DefaultGui 
		Last_DefaultListView := A_DefaultListView
		;Set Default to LogGUI
		Gui, %LogGUI%:Default 
		Gui, %LogGUI%:ListView, % This.LVHwnd[ProfileName]
		LV_Add("", ts, FunctionName, Text)
		; Set Default Back
		Gui, %Last_DefaultGui%:Default 
		Gui, %Last_DefaultGui%:ListView, %Last_DefaultListView%	
	}
	LVDel_FirstRow(ProfileName){
		LogGUI := This.LogGUI
		;Save Last
		Last_DefaultGui := A_DefaultGui 
		Last_DefaultListView := A_DefaultListView
		;Set Default to LogGUI
		Gui, %LogGUI%:Default 
		Gui, %LogGUI%:ListView, % This.LVHwnd[ProfileName]
		LV_Delete(1) ; Delete First Row
		; Set Default Back
		Gui, %Last_DefaultGui%:Default 
		Gui, %Last_DefaultGui%:ListView, %Last_DefaultListView%	
	}

	CreateLogGUI(){
		This.ProgressBar := {}
		This.ProgressBar.HwndPB := {}
		This.ProgressBar.HwndText := {}
		This.ProgressBar.Index := []
		This.LVHwnd := {}
		for i,v in This.LogProfile.List{
			Group_Tab_Name .= v "|"
		}
		Gui, New, +HwndLogGUI
		This.LogGUI := LogGUI
		this.events := new this.EventHook(LogGUI, this.controls, This.ExitOnClose)
		Gui, %LogGUI%:Add, Tab3,, %Group_Tab_Name%
		for i,ProfileName in This.LogProfile.List{
			Gui, %LogGUI%:Tab, %ProfileName%
			Gui, %LogGUI%:Add, ListView, r20 w710 hwndhwndLV , Time|Func|Detail
			This.LVHwnd[ProfileName] := hwndLV
			BoundFunc := ObjBindMethod(This, "LogToClip")
			GuiControl, +g, %hwndlv% , %BoundFunc%
			LV_ModifyCol(1, 80)
			LV_ModifyCol(2, 120)
			LV_ModifyCol(3, 500)
			_Add_PG := This.LogProfile[ProfileName]._AddProgress
			Loop, Parse, _Add_PG, %A_Space%
			{
				if(A_LoopField =""){
					Continue
				}
				Gui, %LogGUI%:Add, Progress, x22 y+10 w710 h19 border +c00dd00 hwndPGBHwnd, 0
				Gui, %LogGUI%:Add, Text, x27 y+-16 w240 +BackgroundTrans, %A_LoopField%
				Gui, %LogGUI%:Add, Text, x12 y+-13 w700 +BackgroundTrans Center hwndTextPercent, % A_Tab "0`%"
				if !(This.ProgressBar.HwndPB.HasKey(A_LoopField)){
					This.ProgressBar.HwndPB[A_LoopField] := []
					This.ProgressBar.HwndText[A_LoopField] := []
					This.ProgressBar.Index.Push(A_LoopField)
				}
				This.ProgressBar.HwndPB[A_LoopField].push(PGBHwnd)
				This.ProgressBar.HwndText[A_LoopField].push(TextPercent)
			}
		}
		GuiX := This.LogProfile._GuiSetting.x
		GuiY := This.LogProfile._GuiSetting.y
		Gui, %LogGUI%:Show, x%GuiX% y%GuiY% , AHK - LOG
		Gui, 1:New
	}

	LogToClip(){
		LogGUI := This.LogGUI
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
		This.ProgressBar
		for i,PGNAME in This.ProgressBar.Index
		{
			if (Name = PGNAME)
			{
				for i,HwndPG in This.ProgressBar.HwndPB[PGNAME]
				{
					GuiControl, , %HwndPG% , % Floor(Percent)
				}
				for i,HwndTX in This.ProgressBar.HwndText[PGNAME]
				{
					GuiControl, , %HwndTX% , % A_Tab Round(Percent, 2) " `%"
				}
			}
		}
	}

	LogAppend(text, path){
		f := FileOpen(path, "a")
		f.Write(text)
		f.Close()
	}

	__Delete() {
		try Gui, % this.hwnd . ":Destroy"
		this.events.Clear()
	}
   
	class EventHook
	{
		__New(hGui, controls, ExitOnClose) {
			this.ExitOnClose := ExitOnClose
	    	this.hGui := hGui
	    	this.controls := controls
	    	this.OnSysCommand := ObjBindMethod(this, "WM_SYSCOMMAND")
	    	OnMessage(0x112, this.OnSysCommand)
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

}
















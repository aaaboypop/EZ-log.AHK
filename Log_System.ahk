If(A_ScriptName="Log_System.ahk"){
	MsgBox, 0x10, Error, This File is path of main.ahk`, Don't run this file directly,
	ExitApp
}

LoadLogSetting(){
	global LogProfile, Logs
	FileCreateDir, %A_ScriptDir%\Logs
	SettingPath = %A_ScriptDir%\Setting.ini
	
	If (!FileExist(SettingPath)){
		DefaultSetting =
		(
[User]
_LogLimit=999
_WriteFile=False
_AddGUI=True
User=1

[TestArea]
_LogLimit=999
_WriteFile=False
_AddGUI=True
Test=1
		)
		FileAppend, %DefaultSetting%, %SettingPath%
	}
	FileRead, Setting, %SettingPath%

	Logs:={}
	LogProfile := {}
	LogProfile.List := []
	Loop, Parse, Setting, `n, `r
	{
		i := A_index
		If RegExMatch(A_LoopField, "O)^\[(.*)\]$" , ObjMatch)
		{
			ProfileName := ObjMatch.Value(1)
			LogProfile[ProfileName] := {}
			Logs[ProfileName] := []
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
		}
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
	FileAppend, % ts Text "`n", %A_ScriptDir%\logs\Log_%ProfileName%.log
}

AddGuiLog(ProfileName, FunctionName ,Text, TimeStamp:=True){
	If (TimeStamp){
		FormatTime, ts , YYYYMMDDHH24MISS, HH:mm:ss
		ts := ts " : "	
	}

	;Save Last
	Last_DefaultGui := A_DefaultGui 
	Last_DefaultListView := A_DefaultListView
	;Set Default to LogGUI
	Gui, LogGUI:Default 
	Gui, LogGUI:ListView, GuiLV_%ProfileName%	
	LV_Add("", ts, FunctionName, Text)
	; Set Default Back
	Gui, %Last_DefaultGui%:Default 
	Gui, %Last_DefaultGui%:ListView, %Last_DefaultListView%	
}

CreateLogGUI(){
	global

	for i,v in LogProfile.List{
		Group_Tab_Name .= v "|"
	}
	Gui, LogGUI:New, +HwndLogGUI
	Gui, LogGUI:Add, Tab3,, %Group_Tab_Name%

	for i,v in LogProfile.List{
		Gui, LogGUI:Tab, %v%
		Gui, LogGUI:Add, ListView, r20 w710 vGuiLV_%v% , Time|Func|Detail
		LV_ModifyCol(1, 80)
		LV_ModifyCol(2, 120)
		LV_ModifyCol(3, 500)
	}
	Gui, LogGUI:Show,, AHK - LOG
	Gui, 1:New
}

LVDel_FirstRow(ProfileName){
	global LogGUI
	;Save Last
	Last_DefaultGui := A_DefaultGui 
	Last_DefaultListView := A_DefaultListView
	;Set Default to LogGUI
	Gui, LogGUI:Default 
	Gui, LogGUI:ListView, GuiLV_%ProfileName%	
	LV_Delete(1) ; Delete First Row
	; Set Default Back
	Gui, %Last_DefaultGui%:Default 
	Gui, %Last_DefaultGui%:ListView, %Last_DefaultListView%	
}
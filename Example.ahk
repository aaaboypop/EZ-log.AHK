#Include, Log_System.ahk

; this version not support multiple log gui, use Log_System_class.ahk instead

; LogSystem parameters
; FilePath := ""          setting file path
; ExitOnClose := 0        exit on close gui
; DirectSetting := ""     direct setting from this var / if not set, use the setting from the file !! Caution if gui is blank may cause from this or wrong setting file !!
; HideGUI := False        default gui hide, can use GuiHide(), GuiShow() to show/hide the gui

; sample setting
; [Profiles2]               <- profile name
; _LogLimit=999             <- log limit for gui
; _WriteFile=False          <- write to log file
; _AddGUI=True              <- add to gui
; _AddProgress=PG1 aaaaaa   <- add progress bar "PG1" and "aaaaaa" to gui, separated by space

; Test=1                        <- namespace "Test" and Level "1" will add to this profile
; User=2                        <- namespace "User" and Level "2" will add to this profile
; User=1,2 <- **NOT support many level namespace**

; [_GuiSetting]             <- gui setting
; x=400                         <- start gui x position
; y=400                         <- start gui y position

setting =
(
[_GuiSetting]
x=0
y=0

[Profiles1]
_LogLimit=999
_WriteFile=True
_AddGUI=True
_AddProgress=PG1 aaaaaa
Test=1
User=2
zzz=1

[Profiles2]
_LogLimit=999
_WriteFile=False
_AddGUI=True
_AddProgress=PG2
User=1
)

; create log gui
LoadLogSetting("", 1,setting,,A_ScriptDir . "\parth for log file") ; use direct setting from var above, hide gui, set log file dir
CreateLogGUI()

zzz()

LogAdd("User", [1], "asdasdasdas") ; this text will be added to Profiles2(User=1)
LogAdd("Test", [1], "WOW") ; Profiles1(Test=1)
LogRAdd("User", [1,2], ["Waiting Page", "Capturing", "Save Image"]) ; multiple log to Profiles1(User=2), Profiles2(User=1)
LogAdd("User", [1,2], "END") ; Profiles1(User=2), Profiles2(User=1)
LogRAdd("User", [1], ["1", "2", "3"]) ; multiple log to Profiles2(User=1)

LogPG("aaaaaa", 50) ; change progress bar "aaaaaa" in Profiles1 to 50
LogPG("Test", 30) ; notting happen, because Test is not setted in any profile > _AddProgress
LogPG("PG1", 100) ; change progress bar "PG1" in Profiles1 to 100
Return

F1::
LogGuiHide()

; can get the hwnd of the gui by this
; hwnd := LogGUI
Return

F2::
LogGuiShow()
Return

zzz(){
    LogRAdd(A_ThisFunc, [1], ["hi", "yo", "Oo Ee A E A"])
}
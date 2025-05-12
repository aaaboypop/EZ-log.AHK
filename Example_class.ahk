#Include, Log_System_class.ahk

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
doSomeThing=1

[Profiles2]
_LogLimit=999
_WriteFile=False
_AddGUI=True
_AddProgress=PG2
User=1
)

; create 2 log gui
global log := new LogSystem("", 1, setting, , A_ScriptDir . "\parth for log file") ; use direct setting from var above, hide gui, set log file dir
global log1 := new LogSystem("setting.ini", 0,, true) ; use setting from file setting.ini, if not exist will auto create default setting

log.LogAdd("User", [1], "asdasdasdas") ; this text will be added to Profiles2(User=1)
log.LogAdd("Test", [1], "WOW") ; Profiles1(Test=1)
log.LogRAdd("User", [1,2], ["Waiting Page", "Capturing", "Save Image"]) ; multiple log to Profiles1(User=2), Profiles2(User=1)
log.LogAdd("User", [1,2], "END") ; Profiles1(User=2), Profiles2(User=1)
log.LogRAdd("User", [1], ["1", "2", "3"]) ; multiple log to Profiles2(User=1)

log.LogPG("aaaaaa", 50) ; change progress bar "aaaaaa" in Profiles1 to 50
log.LogPG("Test", 30) ; notting happen, because Test is not setted in any profile > _AddProgress
log.LogPG("PG1", 100) ; change progress bar "PG1" in Profiles1 to 100

doSomeThing()

; same as above, but using "log1" for multiple log sample
log1.LogRAdd("User", [1], ["1", "2", "3"])
log1.LogAdd("Test", [1], "awwww test to log1")
log1.LogPG("aaaaaa", 22)
log1.LogPG("Test", 66)
log1.LogPG("PG1", 77)
Return

; sample for gui hide/show
F1::
log.GuiHide()
log1.GuiHide()

; can get the hwnd of the gui by this
; hwnd := log1.LogGUI
Return

F2::
log.GuiShow()
log1.GuiShow()
Return

; sample use case
doSomeThing(){
    log.LogAdd(A_ThisFunc, [1], "hi")
}

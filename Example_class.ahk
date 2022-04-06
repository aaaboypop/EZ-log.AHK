#Include, Log_System_class.ahk



log := new LogSystem("Setting.ini", 1)
log1 := new LogSystem("Setting.ini")


log.LogAdd("User", [1], "asdasdasdas")
log.LogAdd("Test", [1], "WOW")
log.LogRAdd("User", [1,2], ["Waiting Page", "Capturing", "Save Image"])
log.LogAdd("User", [1,2], "END")
log.LogRAdd("User", [1], ["1", "2", "3"])
log.LogPG("aaaaaa", 50)
log.LogPG("Test", 30)
log.LogPG("PG1", 100)

log1.LogRAdd("User", [1], ["1", "2", "3"])
log1.LogAdd("Test", [1], "awwww test to log1")
log1.LogPG("aaaaaa", 22)
log1.LogPG("Test", 66)
log1.LogPG("PG1", 77)
Return

F1::
hwnd := log1.LogGUI
Gui, %hwnd%:Show
Return
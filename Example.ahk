#Include, Log_System.ahk

LoadLogSetting("Setting.ini", 1)
CreateLogGUI()

zzz()

LogPG("aaaaaa", 50)
LogPG("Test", 30)
LogPG("PG1", 100)

zzz(){
    LogAdd("User", [1], "asdasdasdas")
    LogAdd("Test", [1], "WOW")
    LogRAdd("User", [1,2], ["Waiting Page", "Capturing", "Save Image"])
    LogAdd("User", [1,2], "END")
    LogRAdd(A_ThisFunc, [1], ["1", "2", "3"])
}
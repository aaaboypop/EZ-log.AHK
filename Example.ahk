#Include, Log_System.ahk

LoadLogSetting()
CreateLogGUI()

SaveScr()

LogPG("aaaaaa", 50)
LogPG("Test", 30)
LogPG("PG1", 100)



SaveScr(){
    LogAdd("User", [1], "asdasdasdas")
    LogAdd("Test", [1], "WOW")
    LogRAdd("User", [1,2], ["Waiting Page", "Capturing", "Save Image"])
    LogAdd("User", [1,2], "END")
    LogRAdd("User", [1], ["1", "2", "3"])
}

;ExitApp



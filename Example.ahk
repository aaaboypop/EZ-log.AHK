#Include, Log_System.ahk


LoadLogSetting()
CreateLogGUI()
SaveScr()





SaveScr(){
    LogAdd("User", [1], "asdasdasdas")
    LogAdd("Test", [1], "WOW")
    LogRAdd("User", [1,2], ["Waiting Page", "Capturing", "Save Image"])
    LogAdd("User", [1,2], "END")
    LogRAdd("User", [1], ["1", "2", "3"])
}

;ExitApp



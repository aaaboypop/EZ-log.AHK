
#Include, Chrome.ahk
#Include, Log_System.ahk


LoadLogSetting()
CreateLogGUI()
SaveScr()





SaveScr(){
	LogAdd(A_ThisFunc,  [1], "Take ScreenShot")
	LogRAdd(A_ThisFunc, [1,2], ["Waiting Page", "Capturing", "Save Image"])
	LogAdd(A_ThisFunc,  [1,2], "END")
	LogAdd(A_ThisFunc,  [1], "WOW")
	LogAdd(A_ThisFunc,  [1], "1111")
	LogRAdd(A_ThisFunc, [1], ["1", "2", "3"])
}

;ExitApp



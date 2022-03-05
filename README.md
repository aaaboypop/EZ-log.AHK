# EZ-log.AHK
just log system for ahk right?

# How to Install
just include this lib to your file

    #Include, Log_System.ahk
    LoadLogSetting()
    CreateLogGUI()
    
**bam~!!** it's done. ready to work now

# How to use
First thing~! you must edit **Setting.ini** you will see 

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
**[ProfileName]** : This is your log profile name, Naming it's same as variable \
**_LogLimit** : Lenth of log in profile, if log is exceed will drop oldest log (file is not effect) \
**_WriteFile** : Enable to write log file \
**_AddGUI** : Add log data to GUI \
**[FunctionName]=[LogLevel]** \
FunctionName is FunctionName or Group of action name you want to log \
LogLevel it's like a layer, just set them as same level you want to log 

> ProfileName and FunctionName Naming it's same as variable (eg. no space)

Don't understand? just try to use with you self

now! you have 2 option to use
1. **LogAdd** ( FunctionName, LogLvArray, Text )
- FunctionName : FunctionName or Group of action name you want to add log
- LogLvArray : Log Level you want to add
- Text : Text you want to log
2. **LogRAdd** ( FunctionName, LogLvArray, LogAray )
- same as LogAdd, but text input is Array. it's will loop add text until end

# Sample
**setting.ini**

    [User]
    User=1
    
    [TestArea]
    Test=1
    User=2


**code**

    LogAdd("User", [1], "asdasdasdas")
    LogAdd("Test", [1], "WOW")
    LogRAdd("User", [1,2], ["Waiting Page", "Capturing", "Save Image"])
    LogAdd("User", [1,2], "END")
    LogRAdd("User", [1], ["1", "2", "3"])

![Result](https://cdn.discordapp.com/attachments/867434734102511616/947617115060445225/AutoHotkey_8LMeLw59X5.png)

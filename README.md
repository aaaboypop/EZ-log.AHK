# EZ-log.AHK
just log system for ahk right?

# How to Install
just include this lib to your file
```
#Include, Log_System.ahk
LoadLogSetting("setting.ini", 1)
CreateLogGUI()
```   
LoadLogSetting(FilePath, ExitOnClose) \
**FilePath** : your config file path you want to save/read eg. "setting.ini"
**ExitOnClose** : Exit when you close gui (True/False)

**bam~!!** it's done. ready to work now

# How to use
First thing~! you must edit **Setting.ini** you will see 
```
[_GuiSetting]
x=951
y=393

[User]
_LogLimit=999
_WriteFile=False
_AddGUI=True
_AddProgress=bar1 bar3
User=1

[TestArea]
_LogLimit=999
_WriteFile=False
_AddGUI=True
_AddProgress=ssssssaaaa
Test=1
```
**[ProfileName]** : This is your log profile name, Naming it's same as variable \
**_LogLimit** : Lenth of log in profile, if log is exceed will drop oldest log (file is not effect) \
**_WriteFile** : Enable to write log file \
**_AddGUI** : Add log data to GUI \
**[FunctionName]=[LogLevel]** \
FunctionName is FunctionName or Group of action name you want to log \
LogLevel it's like a layer, just set them as same level you want to log \
**_AddProgress=** : Add Progress bar to Profile Gui, it can create multiple by whitespace eg. bar1 bar2 bar3

**[_GuiSetting]** : Default Profile is auto generate when you Exit Gui, It contain key x, y config start position of gui

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
```
[User]
User=1

[TestArea]
Test=1
User=2
```

**code**
```
LogAdd("User", [1], "asdasdasdas")
LogAdd("Test", [1], "WOW")
LogRAdd("User", [1,2], ["Waiting Page", "Capturing", "Save Image"])
LogAdd("User", [1,2], "END")
LogRAdd("User", [1], ["1", "2", "3"])
```
![Result](https://cdn.discordapp.com/attachments/867434734102511616/952333265132466216/AutoHotkey_D2jkLE8TR1.png)

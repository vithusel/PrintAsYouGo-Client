#include "Functions.au3"
#include <MsgBoxConstants.au3>
#include "ConfigSetup.au3"
#include "PrintConfig.au3"

; Define the full process name for NextCloud
Global $processName = "nextcloud.exe"

; Check if the NextCloud process is not running
If Not ProcessExists($processName) Then
    MsgBox($MB_ICONERROR, "NextCloud not running", "NextCloud is currently not running. Please load it via the start menu before launching this program")
	Exit ; Terminate the application  
EndIf

; Define the path to the config file
Global $configFile = @ScriptDir & "\config.ini"

; Check if the config file exists
If Not FileExists($configFile) Then
    ; Launch the Configuration Setup
    ConfigSetup()
Else
    ; Launch the Print Configuration
    PrintConfig()
EndIf

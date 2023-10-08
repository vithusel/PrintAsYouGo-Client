#include "ConfigSetup.au3"
#include "PrintConfig.au3"
#include "Functions.au3"

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

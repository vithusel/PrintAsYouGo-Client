Func ShowAboutDetails()
    MsgBox($MB_ICONINFORMATION, "About", "Application Name: " & $appName & @CRLF & _
        "Version: " & $version & @CRLF & _
        "Developer: " & $developer & @CRLF & _
        "Project Page: " & $projectPage)
EndFunc

Func UpdateConfigFile()
    ; Update the config file with the latest version
    IniWrite($configFile, "Settings", "Version", $version)
EndFunc
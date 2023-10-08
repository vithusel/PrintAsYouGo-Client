#include <GUIConstantsEx.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <ComboConstants.au3>
#include <FileConstants.au3>
#include <StringConstants.au3>
#include <Constants.au3> ; Include Constants.au3 to use @UserProfileDir

Func ConfigSetup()
    ; Create a GUI for user input
    $hMainGUI = GUICreate("Configuration Setup", 500, 300)
    
    ; File System dropdown
    GUICtrlCreateLabel("File System:", 20, 20)
    $hFileSystemCombo = GUICtrlCreateCombo("", 20, 40, 140, 20)
    GUICtrlSetData($hFileSystemCombo, "NextCloud|OneDrive|DropBox|Egnyte|Box|Other") ; Options
    
    ; Location input
    GUICtrlCreateLabel("Location (Folder):", 180, 20)
    $hLocationInput = GUICtrlCreateInput(@UserProfileDir & "\", 180, 40, 220, 20)
    $hBrowseButton = GUICtrlCreateButton("Browse", 400, 40, 80, 20)
    
    ; Configuration options
    GUICtrlCreateLabel("Full Name:", 20, 80)
    $hFullNameInput = GUICtrlCreateInput("", 20, 100, 220, 20)
    
    GUICtrlCreateLabel("Company:", 260, 80)
    $hCompanyInput = GUICtrlCreateInput("", 260, 100, 220, 20)
    
    GUICtrlCreateLabel("Email Address:", 20, 140)
    $hEmailInput = GUICtrlCreateInput("", 20, 160, 220, 20)
    
    ; OK button
    $hOKButton = GUICtrlCreateButton("OK", 150, 210, 100, 30)
    
    ; About button
    $hAboutButton = GUICtrlCreateButton("About", 20, 210, 100, 30)
    
    GUISetState(@SW_SHOW)
    
    ; Wait for the user to interact with the GUI
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                Exit
            Case $hBrowseButton
                $folderPath = FileSelectFolder("Select a folder", @UserProfileDir & "\", 1)
                If Not @error Then
                    GUICtrlSetData($hLocationInput, $folderPath)
                EndIf
            Case $hFileSystemCombo
                ; Show the "Other" input box if "Other" is selected
                If GUICtrlRead($hFileSystemCombo) = "Other" Then
                    $customSystem = InputBox("Other File System", "Enter a custom file system:")
                    ; Check if the user entered something and set the dropdown value
                    If $customSystem <> "" Then
                        GUICtrlSetData($hFileSystemCombo, $customSystem)
                        ; Set the selected item to the custom value
                        GUICtrlSetData($hFileSystemCombo, $customSystem, $customSystem)
                    EndIf
                EndIf
            Case $hOKButton
                ; Retrieve values entered by the user
                $fileSystem = GUICtrlRead($hFileSystemCombo)
                $location = GUICtrlRead($hLocationInput)
                $fullName = GUICtrlRead($hFullNameInput)
                $company = GUICtrlRead($hCompanyInput)
                $email = GUICtrlRead($hEmailInput)
                
                ; Check if all fields have values
                If $fileSystem = "" Or $location = "" Or $fullName = "" Or $company = "" Or $email = "" Then
                    MsgBox($MB_ICONERROR, "Error", "Please fill in all fields.")
                Else
                    ; Check if the folder path exists
                    If Not FileExists($location) Then
                        MsgBox($MB_ICONERROR, "Error", "The specified folder does not exist.")
                    ElseIf StringInStr($email, "@") = 0 Or StringInStr($email, ".", StringLen($email) - 1) = 0 Then
                        MsgBox($MB_ICONERROR, "Error", "Invalid email address format.")
                    Else
                        ; Write the values to the config file
                        IniWrite($configFile, "Settings", "FileSystem", $fileSystem)
                        IniWrite($configFile, "Settings", "Location", $location)
                        IniWrite($configFile, "Settings", "FullName", $fullName)
                        IniWrite($configFile, "Settings", "Company", $company)
                        IniWrite($configFile, "Settings", "EmailAddress", $email)
                        
                        ; Update the config file with the latest version
                        UpdateConfigFile()
                        
                        ; Close the GUI
                        GUIDelete($hMainGUI)
                        
                        ; Rerun the script (restart the application)
                        Run(@AutoItExe & ' "' & @ScriptFullPath & '"', @ScriptDir)
                        
                        ; Exit the current script instance
                        Exit
                    EndIf
                EndIf
            Case $hAboutButton
                ShowAboutDetails()
        EndSwitch
    WEnd
EndFunc

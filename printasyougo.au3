#include <GUIConstantsEx.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <ComboConstants.au3>
#include <FileConstants.au3>

; Define the path to the config file
Global $configFile = @ScriptDir & "\config.ini"

; Check if the config file exists
If Not FileExists($configFile) Then
    ; Create a GUI for user input
    $hMainGUI = GUICreate("Configuration Setup", 400, 220)
    
    ; Location input
    GUICtrlCreateLabel("Location (Folder):", 20, 20)
    $hLocationInput = GUICtrlCreateInput("", 20, 40, 260, 20)
    $hBrowseButton = GUICtrlCreateButton("Browse", 290, 40, 80, 20)
    
    ; Configuration options
    GUICtrlCreateLabel("Full Name:", 20, 80)
    $hFullNameInput = GUICtrlCreateInput("", 20, 100, 350, 20)
    
    GUICtrlCreateLabel("Company:", 20, 120)
    $hCompanyInput = GUICtrlCreateInput("", 20, 140, 350, 20)
    
    GUICtrlCreateLabel("Email Address:", 20, 160)
    $hEmailInput = GUICtrlCreateInput("", 20, 180, 350, 20)
    
    ; OK button
    $hOKButton = GUICtrlCreateButton("OK", 150, 210, 100, 30)
    
    GUISetState(@SW_SHOW)
    
    ; Wait for the user to interact with the GUI
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                Exit
            Case $hBrowseButton
                $folderPath = FileSelectFolder("Select a folder", "")
                If Not @error Then
                    GUICtrlSetData($hLocationInput, $folderPath)
                EndIf
            Case $hOKButton
                ; Retrieve values entered by the user
                $location = GUICtrlRead($hLocationInput)
                $fullName = GUICtrlRead($hFullNameInput)
                $company = GUICtrlRead($hCompanyInput)
                $email = GUICtrlRead($hEmailInput)
                
                ; Write the values to the config file
                IniWrite($configFile, "Settings", "Location", $location)
                IniWrite($configFile, "Settings", "FullName", $fullName)
                IniWrite($configFile, "Settings", "Company", $company)
                IniWrite($configFile, "Settings", "EmailAddress", $email)
                
                ; Close the GUI
                GUIDelete($hMainGUI)
                
                ; Exit the loop
                ExitLoop
        EndSwitch
    WEnd
Else
    ; Create a different GUI for additional options if the config file exists
    $hPrintGUI = GUICreate("Print Configuration", 400, 220)
    
    ; File upload button for PDFs
    GUICtrlCreateLabel("Upload PDF File:", 20, 20)
    $hPDFFileInput = GUICtrlCreateInput("", 20, 40, 260, 20)
    $hBrowsePDFButton = GUICtrlCreateButton("Browse", 290, 40, 80, 20)
    
    ; Print options dropdown for Page Size (A4 or A3)
    GUICtrlCreateLabel("Page Size:", 20, 80)
    $hPageSizeCombo = GUICtrlCreateCombo("", 140, 78, 180, 20, $CBS_DROPDOWNLIST)
    GUICtrlSetData($hPageSizeCombo, "A4|A3")
    
    ; Print options dropdown for Orientation (Portrait or Landscape)
    GUICtrlCreateLabel("Orientation:", 20, 120)
    $hOrientationCombo = GUICtrlCreateCombo("", 140, 118, 180, 20, $CBS_DROPDOWNLIST)
    GUICtrlSetData($hOrientationCombo, "Portrait|Landscape")
    
    ; Print Location dropdown
    GUICtrlCreateLabel("Print Location:", 20, 160)
    $hPrintLocationCombo = GUICtrlCreateCombo("", 140, 158, 180, 20, $CBS_DROPDOWNLIST)
    
    ; Populate Print Location dropdown with subfolders of the configured location
    $location = IniRead($configFile, "Settings", "Location", "")
    $aSubfolders = _FileListToArray($location, "*", $FLTA_FOLDERS)
    If IsArray($aSubfolders) Then
        For $i = 1 To $aSubfolders[0]
            GUICtrlSetData($hPrintLocationCombo, $aSubfolders[$i])
        Next
    EndIf
    
    ; Submit button
    $hSubmitButton = GUICtrlCreateButton("Submit", 150, 190, 100, 30)
    
    GUISetState(@SW_SHOW)
    
    ; Wait for the user to interact with the GUI
    While 1
        $nMsg = GUIGetMsg()
        Switch $nMsg
            Case $GUI_EVENT_CLOSE
                Exit
            Case $hBrowsePDFButton
                $pdfFilePath = FileOpenDialog("Select a PDF file", @WorkingDir, "PDF Files (*.pdf)", 1)
                If Not @error Then
                    GUICtrlSetData($hPDFFileInput, $pdfFilePath)
                EndIf
            ; Add a case for the Submit button
            Case $hSubmitButton
                ; Retrieve the selected PDF file path
                $pdfFilePath = GUICtrlRead($hPDFFileInput)
                ; Retrieve the selected print location
                $selectedLocation = GUICtrlRead($hPrintLocationCombo)
                ; Check if both fields are filled
                If $pdfFilePath <> "" And $selectedLocation <> "" Then
                    ; Extract the filename from the PDF file path
Local $pdfFileName = StringRegExpReplace($pdfFilePath, ".*\\", "")

                    
                    ; Copy the PDF file to the selected print location
                    $destinationPath = $location & "\" & $selectedLocation
                    FileCopy($pdfFilePath, $destinationPath & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_'))
                    
                    ; Create an INI file with page size and orientation information
                    $pageSize = GUICtrlRead($hPageSizeCombo)
                    $orientation = GUICtrlRead($hOrientationCombo)
                    IniWrite($destinationPath & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "PrintSettings", "PageSize", $pageSize)
                    IniWrite($destinationPath & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "PrintSettings", "Orientation", $orientation)
                    
                    MsgBox($MB_ICONINFORMATION, "Success", "PDF file copied and settings saved.")
                Else
                    MsgBox($MB_ICONERROR, "Error", "Please select a PDF file and a print location.")
                EndIf
        EndSwitch
    WEnd
EndIf

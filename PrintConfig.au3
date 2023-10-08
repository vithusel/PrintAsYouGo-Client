#include <GUIConstantsEx.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <ComboConstants.au3>
#include <FileConstants.au3>
#include <DateTimeConstants.au3>
#include <Crypt.au3>

    ; Define the version information
    Global $version = "0.0.1"
    Global $appName = "Print As You Go"
    Global $developer = "Vithurshan Selvarajah"
    Global $projectPage = "https://example.com/printasyougo"
    
Func PrintConfig()
    ; Define the path to the config file
    Global $configFile = @ScriptDir & "\config.ini"
    
    If FileExists($configFile) Then
        ; Create the Print Configuration GUI
        $hPrintGUI = GUICreate("Print Configuration", 400, 350) ; Height set to -1 for auto-adjustment
    
        ; Update the config file with the latest version
        UpdateConfigFile()
    
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
    
        ; Dropdown for Color (Color or Black and White)
        GUICtrlCreateLabel("Color:", 20, 160)
        $hColorCombo = GUICtrlCreateCombo("", 140, 158, 180, 20, $CBS_DROPDOWNLIST)
        GUICtrlSetData($hColorCombo, "Color|Black and White")
    
        ; Checkbox for Delay Print
        $hDelayPrintCheckbox = GUICtrlCreateCheckbox("Delay Print", 20, 200)
        $hDelayPrintDateInput = GUICtrlCreateDate("", 160, 195, 150, 20, $DTS_TIMEFORMAT)
    
        ; Hide date and time input initially
        GUICtrlSetState($hDelayPrintDateInput, $GUI_HIDE)
    
        ; Checkbox for Flatten
        $hFlattenCheckbox = GUICtrlCreateCheckbox("Flatten", 20, 230)
    
        ; Checkbox for Print Location
        GUICtrlCreateLabel("Print Location:", 20, 270)
        $hPrintLocationCombo = GUICtrlCreateCombo("", 140, 268, 180, 20, $CBS_DROPDOWNLIST)
    
        ; Populate Print Location dropdown with subfolders of the configured location
        $location = IniRead($configFile, "Settings", "Location", "")
        $aSubfolders = _FileListToArray($location, "*", $FLTA_FOLDERS)
        If IsArray($aSubfolders) Then
            GUICtrlSetData($hPrintLocationCombo, $aSubfolders[1]) ; Set the default value
            For $i = 2 To $aSubfolders[0]
                GUICtrlSetData($hPrintLocationCombo, $aSubfolders[$i])
            Next
        EndIf
    
        ; Submit button
        $hSubmitButton = GUICtrlCreateButton("Submit", 280, 300, 100, 30)
    
        ; About button
        $hAboutButton = GUICtrlCreateButton("About", 20, 300, 100, 30)
    
        GUISetState(@SW_SHOW)
    
        While 1
            $nMsg = GUIGetMsg()
            Switch $nMsg
                Case $GUI_EVENT_CLOSE
                    Exit ; Exit the script when the GUI is closed
                Case $hBrowsePDFButton
                    $pdfFilePath = FileOpenDialog("Select a PDF file", @WorkingDir, "PDF Files (*.pdf)", 1)
                    If Not @error Then
                        GUICtrlSetData($hPDFFileInput, $pdfFilePath)
                    EndIf
                Case $hSubmitButton
                    ; Call the function to handle PDF printing and settings
                    HandlePDFPrinting($hPDFFileInput, $hPrintLocationCombo, $hPageSizeCombo, $hOrientationCombo, $hColorCombo, $hDelayPrintCheckbox, $hDelayPrintDateInput, $hFlattenCheckbox)
                Case $hAboutButton
                    ShowAboutDetails()
                Case $hDelayPrintCheckbox
                    ; Toggle the visibility of the date and time input when "Delay Print" is checked/unchecked
                    If GUICtrlRead($hDelayPrintCheckbox) Then
                        GUICtrlSetState($hDelayPrintDateInput, $GUI_SHOW)
                    Else
                        GUICtrlSetState($hDelayPrintDateInput, $GUI_HIDE)
                    EndIf
            EndSwitch
        WEnd
    EndIf
EndFunc

Func HandlePDFPrinting($hPDFFileInput, $hPrintLocationCombo, $hPageSizeCombo, $hOrientationCombo, $hColorCombo, $hDelayPrintCheckbox, $hDelayPrintDateInput, $hFlattenCheckbox)
    ; Retrieve the selected PDF file path
    $pdfFilePath = GUICtrlRead($hPDFFileInput)
    ; Retrieve the selected print location
    $selectedLocation = GUICtrlRead($hPrintLocationCombo)
    ; Check if both fields are filled
    If $pdfFilePath <> "" And $selectedLocation <> "" Then
        ; Extract the filename from the PDF file path
        Local $pdfFileName = StringRegExpReplace($pdfFilePath, ".*\\", "")
    
        ; Create the "Printing" folder within the destination path if it doesn't exist
        $location = IniRead($configFile, "Settings", "Location", "")
        $destinationPath = $location & "\" & $selectedLocation
        $printingFolder = $destinationPath & "\Printing"
        If Not FileExists($printingFolder) Then
            DirCreate($printingFolder)
        EndIf
    
        ; Copy the PDF file to the "Printing" folder
        $destinationFilePath = $printingFolder & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_')
        FileCopy($pdfFilePath, $destinationFilePath)
    
        ; Generate MD5 hash of the PDF file
        $md5Hash = _Crypt_HashFile($destinationFilePath, $CALG_MD5)
    
        ; Create an INI file with page size, orientation, and MD5 hash information in the "Printing" folder
        $pageSize = GUICtrlRead($hPageSizeCombo)
        $orientation = GUICtrlRead($hOrientationCombo)
        IniWrite($printingFolder & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "PrintSettings", "PageSize", $pageSize)
        IniWrite($printingFolder & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "PrintSettings", "Orientation", $orientation)
        IniWrite($printingFolder & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "PrintSettings", "MD5Hash", $md5Hash)
    
        ; Check the checkboxes and set their values in the INI file
        $color = GUICtrlRead($hColorCombo)
        $flatten = GUICtrlRead($hFlattenCheckbox)
        $delayPrint = GUICtrlRead($hDelayPrintCheckbox)
    
        IniWrite($printingFolder & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "AdvancedSettings", "Color", $color)
        IniWrite($printingFolder & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "AdvancedSettings", "Flatten", $flatten)
    
        If $delayPrint Then
            ; Store the delay print time in the INI file
            $delayPrintTime = GUICtrlRead($hDelayPrintDateInput)
            IniWrite($printingFolder & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "AdvancedSettings", "DelayPrintTime", $delayPrintTime)
        Else
            ; Clear the delay print time in the INI file
            IniWrite($printingFolder & "\" & StringRegExpReplace($pdfFileName, '[^a-zA-Z0-9_.]', '_') & ".ini", "AdvancedSettings", "DelayPrintTime", "")
        EndIf
    
        MsgBox($MB_ICONINFORMATION, "Success", "PDF file copied to the 'Printing' folder, settings saved, and MD5 hash included in the INI.")
    Else
        MsgBox($MB_ICONERROR, "Error", "Please select a PDF file and a print location.")
    EndIf
EndFunc
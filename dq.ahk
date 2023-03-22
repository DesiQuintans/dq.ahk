/*
dq.ahk v0.2.0
My personal library of general-purpose Autohotkey 2 functions.

github.com/DesiQuintans/dq.ahk
*/


#Requires AutoHotkey v2.0



/**
 * Replaces Send() hotkey symbols with their key names, for display in Help dialogs.
 *
 * @param {String} KeyName    A keyname, as you would use in Send().  
 *
 * @return
 *  {String}
 * 
 * @example
 * ReadableHotkey("#s")
 * ; "Win+S"
 * 
 */
dq_ReadableHotkey(KeyName) {
    out := StrUpper(KeyName)

    out := StrReplace(out, "+", "Shift+") 
    out := StrReplace(out, "#", "Win+") 
    out := StrReplace(out, "^", "Ctrl+") 
    out := StrReplace(out, "!", "Alt+")
    out := StrReplace(out, "{", "")
    out := StrReplace(out, "}", "")

    return(out)
}




/**
 * Takes a full path and returns the file's basename and its parent directory for context.
 *
 * @param {String} Filename    A full path to the file.
 *
 * @return {String}
 * 
 * @example
 * ReadableFilename("C:\Docs\Project7\Notes.txt")
 * ; "Project7\Notes.txt"
 * 
 */
dq_ReadableFilename(Filename) {
    split_Filename := StrSplit(Filename, "\")

    return(split_Filename[-2] . "\" . split_Filename[-1])
}


/**
 * Return a file's basename and extension.
 *
 * @param      {String} Filename  A full path to a file.
 *
 * @return     {String}
 * 
 * @example
 * Basename("C:\Docs\Project7\Notes.txt")
 * ; " Notes.txt"
 * 
 */
dq_Basename(Filename) {
    split_Filename := StrSplit(Filename, "\")

    return(split_Filename[-1])
}


/**
 * @brief      Put a * at the start of a GUI's window title. Often used to show unsaved changes.
 *
 * @param      {GuiObj} GuiObj  The GUIObj to affect.
 *
 * @return     Side-effect (changes the GuiObj's title), but returns nothing.
 * 
 * @example
 * MyGui := Gui(, "My window's title")
 *
 * FlagTitle(MyGui)    ; "* My window's title"
 * UnflagTitle(MyGui)  ; "My window's title"
 * 
 */
dq_FlagTitle(GuiObj) {
    if not RegExMatch(GuiObj.Title, "^\* ") {
        GuiObj.Title := "* " . GuiObj.Title
    }
}


/**
 * Remove * from the start of a GUI's window title, previously set by dq_FlagTitle().
 *
 * @param      {GuiObj} GuiObj  The GUIObj to affect.
 *
 * @return     Side-effect (Changes GuiObj's title), but returns nothing.
 * 
 * @example
 * MyGui := Gui(, "My window's title")
 * 
 * FlagTitle(MyGui)    ; "* My window's title"
 * UnflagTitle(MyGui)  ; "My window's title"
 * 
 */
dq_UnflagTitle(GuiObj) {
    GuiObj.Title := RegExReplace(GuiObj.Title, "^\* ", "")
}


/**
 * @brief      Toggles whether a GUI is hidden or not hidden.
 *
 * @param      {GuiObj} GuiObj  The GuiObj to affect.
 *
 * @return     Side-effect (toggle GuiObj's visibility), but returns nothing.
 * 
 * @example
 * MyGui := Gui(, "My window's title")
 * #s::GuiToggleVisibility(MyGui)  ; Show/hide MyGui when Win+S is pressed.
 * 
 */
dq_GuiToggleVisibility(GuiObj) {
    If DllCall("IsWindowVisible", "Ptr", WinExist("ahk_id " . GuiObj.Hwnd))
    {
        GuiObj.Hide()
    }
    else
    {
        GuiObj.Show()
    }
}


/**
 * Handles both Save and Save As functionality, depending on whether a Filename is set or not.
 *
 * @param      {String} Contents         The contents of the new file
 * @param      {String} [Filename]       The target file path. If unset, show a File Select dialog.
 * @param      {String} [SuggestedName]  A filename to pre-fill the File Select dialog with. 
 *                                       By default, suggests a text file named with today's date.
 * @param      {String} [DialogTitle]    A custom title for the File Select dialog.
 * @param      {String} [FileFilter]     A filter that selects which files are visible in the dialog. 
 *                                       See 'FileSelect' in the AHK docs for more information.
 *
 * @return     {Object} An object with two named values: 1
 */
dq_SaveFile(Contents, Filename?, SuggestedName := Format("{1}-{2}-{3}.txt", A_Year, A_Mon, A_MDay), DialogTitle := "", FileFilter := "Plain text (*.txt; *.md; *.markdown; *.org)") {
    /*
    Handles both Save and Save As functionality, depending on whether a Filename is set or not.
    
    Contents        - The contents of the new file
    [Filename]      - The target file path.
    [SuggestedName] - 
    [DialogTitle]   - A custom title for the File Select dialog.
    [FileFilter]    - A filter that selects which files are visible in the dialog. See 'FileSelect' 
                      in the AHK docs for more information.
    
    Return: 
        An object with two named values: 
            1. path  --- The path to the file
            2. err   --- If the file wasn't saved, 1. Else, 0. 
    
    Examples:
        ; If Filename is unset, it launches the File Select dialog.
        dq_SaveFile("my contents")  

        ; If Filename is set, tries to save to that file.
        ; If Filename is set but the file does not exist, launches the File Select dialog.
        dq_SaveFile("my contents", "myfile.txt")
    */

    if not IsSet(Filename) or Filename == "" {
        ; Launch the File Select dialog to return a Filename
        Filename := FileSelect("S24", SuggestedName, DialogTitle, FileFilter)

        if Filename == "" {
            ; If Filename is still blank, it's because the user hit Cancel in 
            ; the File Select dialog.
            return({path: "", err: 1})
        }
    }   

    ; Try to save to Filename
    if FileExist(Filename) {
        FileDelete(Filename)
    }

    FileAppend(Contents, Filename, "UTF-8")

    if FileExist(Filename) {
        return({path: Filename, err: 0})
    } else {
        return({path: "", err: 1})
    }
}


dq_LoadFile(Filename?, DialogTitle := "", FileFilter := "Plain text (*.txt; *.md; *.markdown; *.org)") {
    /*
    Read a file into a variable. 
    
    [Filename]     - The target file path. If unset, show a File Select dialog.
    [DialogTitle]  - A custom title for the File Select dialog.
    [FileFilter]   - A filter that selects which files are visible in the dialog. See
                     'FileSelect' in the AHK docs for more information.
    
    Return: 
        An object with 3 named values:
            1. path     --- path to the loaded file.
            2. contents --- contents of the loaded file.
            3. err      --- If the file wasn't loaded, 1. Else, 0.
    
    Examples:
        ; Filename is unset, so it launches the Select File dialog.
        dq_LoadFile()

        ; If Filename is set, tries to load that file.
        ; If Filename is set but the file does not exist, launches the File Select dialog.
        dq_LoadFile("myfile.txt")  ; Save Only, no selector dialog, save to myfile.txt.
    */


    if not IsSet(Filename) or Filename == "" {
        ; Show the File Select dialog if Filename was not supplied or is blank.
        ; This allows the programmer to pass in "" when dq_LoadFile() is called.
        Filename := FileSelect(3,, DialogTitle, FileFilter)

        if Filename == "" {
            ; If Filename is still blank now, then it's because the user hit Cancel in 
            ; the File Select dialog.
            return({path: "", contents: "", err: 1})
        }
    }

    if not FileExist(Filename) {
        ; If there is no file at the expected path, give the user a chance to retry or exit.

        choice := MsgBox(Format("The file '{1}' does not exist. It may have been moved, renamed, or deleted.`n`nChoose a different file?", 
                      Filename),
                      "File not found", "YesNo Icon!")

        if choice == "Yes" {
            ; The function calls itself again, this time showing the File Select dialog.
            dq_LoadFile(, DialogTitle, FileFilter)
            return
        }

        return({path: "", contents: "", err: 1})
    }

    ; If all is good, return the file.
    return({path: Filename, contents: FileRead(Filename), err: 0})
}


dq_FileNewerThan(Filename, Timestamp) {
    /*
    Was the file at 'Filename' modified after 'Timestamp'?
    
    Filename  - The path to the file.
    Timestamp - The timestamp to compare the file's Modified At time with. The format 
                is YYYYMMDDHH24MISS, like the output from `A_Now`.
    
    Return: 
        An object with 2 named values:
            1. newer  --- 1 if the file was modified after Timestamp, or else 0.
            2. mtime  --- The file's Modified At time.
            3. err    --- 1 if there was a problem (file doesn't exist, etc.), else 0.
    
    Examples:
        myfile := FileModifiedAfter("myfile.txt", "20230131212427") 
    
        if myfile.newer == 1 { 
           ; do something 
        }
    */

    if not FileExist(Filename) {
        return({newer: "", mtime: "", err: 1})
    }

    if (Timestamp == "") {
    	return({newer: "", mtime: "", err: 1})
    }

    filetime := FileGetTime(Filename, "M")

    return({newer: filetime > Timestamp, mtime: filetime, err: 0})
}


dq_EditWidthFromCols(Cols, FontName := "", FontSizePt := "", Debug := 0) {
    /*
    Calculates how wide a multiline Edit control has to be in order to fit n characters of text in 
    one line. AHK already lets us size Edits by number of rows of text, but a matching option to 
    size an Edit by character count is missing.
    
    Cols         - The number of characters that the Edit should fit on one line before wrapping.
    [FontName]   - Calculate using a custom font. Blank ("") uses Windows' defaults.
    [FontSizePt] - Calculate using a custom font size (integer). Blank ("") uses Windows' defaults.
    [Debug]      - If '1', Show the test GUI and its calculated values.

    Return: 
        A number, which is the width (in pixels) that your Edit should in order to fit the number
        of characters you asked for in 'Cols'.
    
    Examples:
        ; Create an Edit that shows 90 columns and 10 rows of text.
        Col90Width := EditWidthFromCols(90)

        MyGui := Gui()
        MyGui.Add("Edit", Format("w{1} R10"), Col90Width))
    */

    RulerGui := Gui()

    ; 1. Set the font of all new controls in this GUI. Blank input reverts to Windows' defaults.
    if FontSizePt != "" {
        FontSizePt := "s" . FontSizePt
    }
    RulerGui.SetFont(FontSizePt, FontName)

    ; 2. How wide is an 'm' in the chosen font?
    EmRuler := RulerGui.Add("Text", "R1", "m")
    EmRuler.GetPos(,, &EmWidth)

    ; 3. How wide is a multi-line Edit control that is automatically sized to fit an 'm'?
    UIRuler := RulerGui.Add("Edit", "multi R4", "m`nm`nm`nm`nm`nm`n")
    UIRuler.GetPos(,, &EditWidth)
    
    ; 4. Calculate sizes
    UIWidth    := EditWidth - EmWidth       ; Width of the Edit's scrollbar, borders, and padding.
    nColsWidth := EmWidth * Cols            ; Text width to fit n Cols
    
    FinalWidth := nColsWidth + UIWidth + 1  ; Total width of desired Edit. Add 1 pixel because if 
                                            ; the fit is TOO exact, the Edit will wrap the last 
                                            ; character anyway.

    ; 6. Optional debugging
    if Debug == 1 {
        RulerGui.Show()

        MsgBox(Format("EmWidth: {1}`n" .
                      "EditWidth: {2}`n" . 
                      "UIWidth: {3}`n" . 
                      "nColsWidth: {4}`n" . 
                      "FinalWidth: {5}",
                      EmWidth, EditWidth, UIWidth, nColsWidth, FinalWidth))
    }

    ; 7. Clean-up and return
    RulerGui.Destroy()
    return(FinalWidth)
}


/**
 * Repeat a string n times
 *
 * @param {String} Str    A string to repeat.
 * @param {Int} N    The number of times to repeat it.  
 *
 * @return
 *  {String}
 * 
 * @example
 * dq_Rep("Hi", 4)
 * ; "HiHiHiHi"
 * 
 */
dq_Rep(Str, N) {
    out := ""

    Loop N {
        out := out . Str
    }

    return(out)
}

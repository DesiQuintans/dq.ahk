/*
dq.ahk v0.2.0
My personal library of general-purpose Autohotkey 2 functions.

github.com/DesiQuintans/dq.ahk
*/


#Requires AutoHotkey v2.0


ReadableHotkey(KeyName) {
    /*
    Replaces Send() hotkey symbols with their key names, for display in Help dialogs.
    
    KeyName - A keyname, as you would use in Send().
    
    Return: 
        String
    
    Examples:
        ReadableHotkey("#s") -> "Win+S"
    */

    out := StrUpper(KeyName)

    out := StrReplace(out, "+", "Shift+") 
    out := StrReplace(out, "#", "Win+") 
    out := StrReplace(out, "^", "Ctrl+") 
    out := StrReplace(out, "!", "Alt+")
    out := StrReplace(out, "{", "")
    out := StrReplace(out, "}", "")

    return(out)
}


ReadableFilename(Filename) {
    /*
    Takes a full path and returns the file's basename and its parent directory (for more context).
    
    Filename - A full path to a file.

    Return:
        String
    
    Examples:
        ReadableFilename("C:\Docs\Project7\Notes.txt") -> "Project7\Notes.txt"
    */

    split_Filename := StrSplit(Filename, "\")

    return(split_Filename[-2] . "\" . split_Filename[-1])
}


Basename(Filename) {
    /*
    Takes a full path and returns the file's basename and extension.
    
    Filename  - A full path to a file.

    Return:
        String
    
    Examples:
        Basename("C:\Docs\Project7\Notes.txt") -> "Notes.txt"
    */

    split_Filename := StrSplit(Filename, "\")

    return(split_Filename[-1])
}


FlagTitle(GuiObj) {
    /*
    Put a * at the start of the window title in the GUI. Often used to show that a file has 
    been edited.
    
    GuiObj - The GuiObj to affect.

    Return: 
        Side-effect (changes GuiObj's title)
    
    Examples:
        MyGui := Gui(, "My window's title")

        FlagTitle(MyGui)    ; "* My window's title"
        UnflagTitle(MyGui)  ; "My window's title"
    */

    if not RegExMatch(GuiObj.Title, "^\* ") {
        GuiObj.Title := "* " . GuiObj.Title
    }
}


UnflagTitle(GuiObj) {
    /*
    Remove * from the start of a window title in a GUI, previously set by FlagTitle().
    
    GuiObj - The GuiObj to affect.

    Return:
        Side-effect (Changes GuiObj's title)
    
    Examples:
        MyGui := Gui(, "My window's title")

        FlagTitle(MyGui)    ; "* My window's title"
        UnflagTitle(MyGui)  ; "My window's title"
    */

    GuiObj.Title := RegExReplace(GuiObj.Title, "^\* ", "")
}


GuiToggleVisibility(GuiObj) {
    /*
    Toggles whether a Gui is hidden or not hidden.

    GuiObj - The GuiObj to affect.
    
    Return:
        Side-effect (toggle GuiObj's visibility)
    
    Examples:
        MyGui := Gui(, "My window's title")
        #s::GuiToggleVisibility(MyGui)  ; Show/hide MyGui when Win+S is pressed.
    */

    If DllCall("IsWindowVisible", "Ptr", WinExist("ahk_id " . GuiObj.Hwnd))
    {
        GuiObj.Hide()
    }
    else
    {
        GuiObj.Show()
    }
}


dq_SaveFile(Contents, Filename?, SuggestedName := Format("{1}-{2}-{3}.txt", A_Year, A_Mon, A_MDay), 
            DialogTitle := "", FileFilter := "Plain text (*.txt; *.md; *.markdown; *.org)") {
    /*
    Handles both Save and Save As functionality, depending on whether a Filename is set or not.
    
    Contents        - The contents of the new file
    [Filename]      - The target file path. If unset, show a File Select dialog.
    [SuggestedName] - A filename to pre-fill the File Select dialog with. By default, suggests a
                      text file named with today's date.
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

    if !IsSet(Filename) {
        ; Launch the File Select dialog to return a Filename
        Filename := FileSelect("S24", SuggestedName, DialogTitle, FileFilter)
    }

   if Filename == "" {
        ; If Filename was supplied, but is blank, then it's likely because the user hit Cancel in 
        ; the File Select dialog.
        return({path: "", err: 1})
    }

    ; Try to save to Filename
    if FileExist(Filename) {
        FileDelete(Filename)
    }

    FileAppend(Contents, Filename, "UTF-8")

    if FileExist(Filename) {
        return({path: Filename, error: 0})
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


    if not IsSet(Filename) {
        ; Show the File Select dialog if Filename was not supplied.
        Filename := FileSelect(3,, DialogTitle, FileFilter)
    }

    if Filename == "" {
        ; If Filename was supplied, but is blank, then it's likely because the user hit Cancel in 
        ; the File Select dialog.
        return({path: "", contents: "", err: 1})
    }

    if not FileExist(Filename) {
        ; If there is no file at the expected path, give the user a chance to retry or exit.

        choice := MsgBox(Format("The file '{1}' does not exist.`nIt may have been moved, renamed, or deleted.`nChoose a different file?", 
                      Filename),
                      "File not found", "OKCancel Icon!")

        if choice == "OK" {
            ; The function calls itself again, this time showing the File Select dialog.
            dq_LoadFile(, DialogTitle, FileFilter)
            return
        }

        return({path: "", contents: "", err: 1})
    }

    ; If all is good, return the file.
    return({path: Filename, contents: FileRead(Filename), err: 0})
}


FileNewerThan(Filename, Timestamp) {
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

    filetime := FileGetTime(Filename, "M")

    return({newer: filetime > Timestamp, mtime: filetime, err: 0})
}
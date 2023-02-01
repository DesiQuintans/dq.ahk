# dq.ahk

My (Desi's) personal library for AutoHotkey 2 <https://www.autohotkey.com/>.



## Usage

Download `dq.ahk` and `Include` it near the top of your script:

```
#Requires AutoHotkey v2.0
#Include "path/to/dq.ahk"
```



## Function documentation

Functions are documented in the script with comments in a standard format. For example:

```
MyFunction(RequiredArg, OptionalArg1?, OptionalArg2 := "") {
    /*
    Description of what this function does.
    
    RequiredArg    - What this parameter is for, and what it accepts.
    [OptionalArg1] - Optional arguments are shown in [square brackets].
    [OptionalArg2] - ...
    
    Return: 
        What the function returns. If it returns an array or an object with named values, then:
            1. named1  --- The contents of the array index or named value.
            2. named2  --- ...
    
    Examples:
        ; Examples of how to use the function and what it outputs.
    */

    ; ...
}
```


## List of functions

- `ReadableHotkey(KeyName)`
    - Replaces `Send()` hotkey symbols with human-readable key names, e.g. "#^s" to "Win+Ctrl+S".

- `ReadableFilename(Filename)`
    - Takes a file's full path and returns its basename and parent folder for context, e.g. "C:\Docs\Project7\Notes.txt" to "Project7\Notes.txt".

- `FlagTitle(GuiObj)`
    - Put a `* ` at the start of the GUI's window title. Usually used to indicate unsaved changes to the current file.

- `UnflagTitle(GuiObj)`
    - Remove `* ` from the start of the GUI's window title.

- `GuiToggleVisibility(GuiObj)`
    - Toggles whether a GUI is hidden or not.

- `dq_SaveFile(Contents, [Filename, SuggestedName, DialogTitle, FileFilter])`
    - Handles both Save and Save As functionality, as well as cases where the user cancels the operation.

- `dq_LoadFile([Filename, DialogTitle, FileFilter])`
    - Handles file loading with or without a File Select dialog, and handles cases where the user cancels the operation.


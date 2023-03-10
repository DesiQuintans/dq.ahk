# NEWS

## v0.2.0 (2023-02-05)

- **Added**
    - `Basename(Filename)`
    - `EditWidthFromCols(Cols, [FontName, FontSizePt, Debug])`
- **Changed**
    - dq_LoadFile()'s "The file doesn't exist. Choose a different file?" dialog now has "Yes/No" options instead of "OK/Cancel".
- **Deprecated**
- **Removed**
- **Fixed**
    - dq_SaveFile() and dq_LoadFile() can handle the user clicking Cancel in the File Select dialog.
    - Typo in 'err' named return value in dq_SaveFile()
- **Security**


## v0.1.0 (2023-02-01)

- **Added**
    - `ReadableHotkey(KeyName)`
    - `ReadableFilename(Filename)`
    - `FlagTitle(GuiObj)`
    - `UnflagTitle(GuiObj)`
    - `GuiToggleVisibility(GuiObj)`
    - `dq_SaveFile(Contents, [Filename, SuggestedName, DialogTitle, FileFilter])`
    - `dq_LoadFile([Filename, DialogTitle, FileFilter])`
- **Changed**
- **Deprecated**
- **Removed**
- **Fixed**
- **Security**



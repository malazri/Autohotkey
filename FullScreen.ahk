#Persistent ; Keeps the script running in the background
OnExit, RestoreTaskbar ; Safety net for the taskbar

TargetApp := "WsaClient.exe" 
TaskbarHidden := false

; Run the scanner every 250ms to catch new windows instantly
SetTimer, WindowScanner, 250
return

; --- DYNAMIC WINDOW SCANNER ---
WindowScanner:
; Grab a list of all active windows belonging to WsaClient.exe
WinGet, wsaList, List, ahk_exe %TargetApp%

; If no WSA windows exist at all, restore the taskbar and stop
if (wsaList == 0)
{
    if (TaskbarHidden)
    {
        WinShow, ahk_class Shell_TrayWnd
        WinShow, ahk_class Shell_SecondaryTrayWnd
        TaskbarHidden := false
    }
    return
}

; If we reached here, at least one WSA window is open. Hide the taskbars.
if (!TaskbarHidden)
{
    WinHide, ahk_class Shell_TrayWnd
    WinHide, ahk_class Shell_SecondaryTrayWnd
    TaskbarHidden := true
}

; Loop through every single discovered WSA window
Loop, %wsaList%
{
    thisID := wsaList%A_Index%
    
    ; Ignore the window if it's currently minimized
    WinGet, minMax, MinMax, ahk_id %thisID%
    if (minMax == -1)
        continue
        
    ; Check if this specific window already has the Popup style (+0x80000000)
    WinGet, thisStyle, Style, ahk_id %thisID%
    if !(thisStyle & 0x80000000) 
    {
        WinRestore, ahk_id %thisID%
        WinSet, Style, -0xCF0000, ahk_id %thisID%  ; Strip standard styles
        WinSet, Style, +0x80000000, ahk_id %thisID% ; Apply Popup style
        WinMove, ahk_id %thisID%, , 0, 0, %A_ScreenWidth%, %A_ScreenHeight%
        WinSet, AlwaysOnTop, On, ahk_id %thisID%
    }
}
return

; --- SAFETY NET ---
RestoreTaskbar:
WinShow, ahk_class Shell_TrayWnd
WinShow, ahk_class Shell_SecondaryTrayWnd
ExitApp
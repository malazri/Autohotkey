#Persistent
#NoEnv
SetBatchLines, -1

; --- CONFIGURATION ---
FontName := "Segoe UI Variable Text"
FontSize := 10        ; Increased font size
TextColor := "000000" ; Solid Black text
IdleColor := "777777" ; Grey arrow when no traffic
UpColor   := "0055FF" ; Blue arrow for active Upload
DownColor := "00AA00" ; Green arrow for active Download
RefreshRate := 1000

;; --- UI CREATION ---
Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, Color, 111111
WinSet, TransColor, 111111

; Separate the Arrows from the Text
Gui, Font, s%FontSize% c%IdleColor% w700, %FontName%
Gui, Add, Text, vArrowUp w15 X0 Y0, ↑
Gui, Add, Text, vArrowDown w15 X0 Y18, ↓

Gui, Font, s%FontSize% c%TextColor% w600, %FontName%
Gui, Add, Text, vTextUp w80 X15 Y0, 0.0 KB/s
Gui, Add, Text, vTextDown w80 X15 Y18, 0.0 KB/s

; --- TASKBAR INJECTION (Forced Bottom-Left) ---
; Get the main Taskbar handle
TaskbarID := WinExist("ahk_class Shell_TrayWnd")

; Set the window style to be a 'Child' of the taskbar
Gui, +Parent%TaskbarID% -Caption +ToolWindow +AlwaysOnTop

; Increase 'y' to move the widget down. 'y10' or 'y12' usually centers it 
; perfectly on a standard Windows 11 taskbar.
Gui, Show, x5 y2 w100 h40 NA, Win11NetMeter

; --- TASKBAR INJECTION (Prevents hiding on click) ---
TaskbarID := WinExist("ahk_class Shell_TrayWnd")
GuiID := WinExist() ; Gets the HWND of our GUI

; Attach our widget natively into the Taskbar
DllCall("SetParent", "ptr", GuiID, "ptr", TaskbarID)

; Show the GUI. Because it is now inside the taskbar, x15 y5 means 
; 15 pixels from the far-left edge of the taskbar itself.
Gui, Show, x15 y5 w100 h40 NA, Win11NetMeter

; Grab baseline network metrics and fire the timer loop
GetNetworkBytes(OldIn, OldOut)
SetTimer, UpdateSpeed, %RefreshRate%
return

; --- UPDATED SPEED SAMPLING LOOP ---
UpdateSpeed:
GetNetworkBytes(NewIn, NewOut)

; Calculate changes using the correct pairs
BytesIn := NewIn - OldIn
BytesOut := NewOut - OldOut

; Save current for next loop
OldIn := NewIn
OldOut := NewOut

; --- DYNAMIC COLORS ---
UpStatusColor := (BytesOut > 1024) ? DownColor : "FF0000"
DownStatusColor := (BytesIn > 1024) ? DownColor : "FF0000"

; 1. Update Arrow Up
Gui, Font, s%FontSize% c%UpStatusColor% w700, %FontName%
GuiControl, Font, ArrowUp
GuiControl,, TextUp, % FormatBytes(BytesOut)

; 2. Update Arrow Down
Gui, Font, s%FontSize% c%DownStatusColor% w700, %FontName%
GuiControl, Font, ArrowDown
GuiControl,, TextDown, % FormatBytes(BytesIn)

; 3. Reset Global Font to Black
Gui, Font, s%FontSize% c%TextColor% w600, %FontName%
return

; --- SYSTEM WMI QUERY ---
GetNetworkBytes(ByRef InBytes, ByRef OutBytes) {
    static wmi := ""
    if (!wmi)
        wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
    
    InBytes := 0, OutBytes := 0
    for item in wmi.ExecQuery("Select BytesReceivedPerSec, BytesSentPerSec from Win32_PerfRawData_Tcpip_NetworkInterface") {
        InBytes += item.BytesReceivedPerSec
        OutBytes += item.BytesSentPerSec
    }
}

FormatBytes(bytes) {
    if (bytes < 1024)
        return bytes . " B/s"
    else if (bytes < 1048576)
        return Round(bytes / 1024, 1) . " KB/s"
    else
        return Round(bytes / 1048576, 1) . " MB/s"
}
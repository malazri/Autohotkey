#Persistent
#NoEnv
SetBatchLines, -1

; --- CONFIGURATION ---
FontName := "Segoe UI Variable Text"
FontSize := 10
TextColor := "000000"
DownColor := "00AA00" ; Green
RedColor  := "FF0000" ; Red
RefreshRate := 1000

; --- OS DETECTION AND SETUP ---
if (A_OSVersion >= "10.0.22000") { ; Windows 11 build number check
    TargetMode := "Win11"
} else {
    TargetMode := "Win10"
}

Gui, +LastFound +AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, Color, 111111
WinSet, TransColor, 111111

Gui, Font, s%FontSize% c%RedColor% w700, %FontName%
Gui, Add, Text, vArrowUp w15 X0 Y0, ↑
Gui, Add, Text, vArrowDown w15 X0 Y18, ↓

Gui, Font, s%FontSize% c%TextColor% w600, %FontName%
Gui, Add, Text, vTextUp w80 X15 Y0, 0.0 KB/s
Gui, Add, Text, vTextDown w80 X15 Y18, 0.0 KB/s

; --- DYNAMIC POSITIONING LOGIC ---
if (TargetMode == "Win11") {
    TaskbarID := WinExist("ahk_class Shell_TrayWnd")
    Gui, +Parent%TaskbarID%
    Gui, Show, x5 y12 w100 h40 NA, Win11NetMeter
} else {
    ; Windows 10: Find Tray area and position to the left of it
    SetTimer, PositionWin10, 500
}

GetNetworkBytes(OldIn, OldOut)
SetTimer, UpdateSpeed, %RefreshRate%
return

; --- WINDOWS 10 TRAY DYNAMICS ---
PositionWin10:
ControlGetPos, TX, TY, TW, TH, TrayNotifyWnd1, ahk_class Shell_TrayWnd
if (TX > 0) {
    ; Anchor to the left of the System Tray
    Gui, Show, % "x" (TX - 105) " y5 w100 h40 NA", Win10NetMeter
}
return

; --- UPDATED SPEED SAMPLING LOOP ---
UpdateSpeed:
; Get the current speed directly
GetNetworkBytes(BytesIn, BytesOut)

; 1. PRE-CALCULATE COLORS
UpColor := (BytesOut > 1024) ? DownColor : RedColor
DownColorVar := (BytesIn > 1024) ? DownColor : RedColor

; 2. Update Arrow Up
Gui, Font, s%FontSize% c%UpColor% w700, %FontName%
GuiControl, Font, ArrowUp
GuiControl,, TextUp, % FormatBytes(BytesOut)

; 3. Update Arrow Down
Gui, Font, s%FontSize% c%DownColorVar% w700, %FontName%
GuiControl, Font, ArrowDown
GuiControl,, TextDown, % FormatBytes(BytesIn)

; 4. Reset Global Font to Black
Gui, Font, s%FontSize% c%TextColor% w600, %FontName%
return

; --- UTILITIES ---
GetNetworkBytes(ByRef InBytesPerSec, ByRef OutBytesPerSec) {
    static wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\.\root\cimv2")
    InBytesPerSec := 0
    OutBytesPerSec := 0
    
    ; Query the 'Formatted' data which gives us bytes/sec directly
    for item in wmi.ExecQuery("Select BytesReceivedPerSec, BytesSentPerSec from Win32_PerfFormattedData_Tcpip_NetworkInterface") {
        InBytesPerSec += item.BytesReceivedPerSec
        OutBytesPerSec += item.BytesSentPerSec
    }
}

FormatBytes(bytes) {
    return (bytes < 1024) ? bytes . " B/s" : (bytes < 1048576) ? Round(bytes / 1024, 1) . " KB/s" : Round(bytes / 1048576, 1) . " MB/s"
}

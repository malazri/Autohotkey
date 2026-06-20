##AutoHotkey Automation Suite

Welcome to my repository of custom Windows automation scripts. These tools are designed to bridge functional gaps in the Windows interface, providing lightweight, native-feeling enhancements for task management and system monitoring.

🚀 The Concept

Windows is a powerful OS, but it often lacks granular control over window states, taskbar behavior, and specialized desktop utilities. This collection of AutoHotkey scripts uses the Windows API to:
Force Window States: Override default application behaviors to enforce true, borderless full-screen modes.
System Injection: Directly inject custom widgets into the Windows Taskbar to create a "native" UI experience without installing bloated third-party software.
Environment-Aware Logic: Automatically detect OS versions (Windows 10 vs. 11) to adapt positioning and functionality dynamically.

🛠 Prerequisites

You will need to install the AutoHotkey (v1.1) engine to run these scripts:
Download the installer from the official AutoHotkey website.

Run the installer and ensure you select the v1.1 (Unicode) version.

📖 How to Install & Use

1. Running Scripts Manually
Download the .ahk file from this repository.
Double-click the file. You will see a green "H" icon appear in your Windows System Tray.
The script is now active and monitoring your system.

2. Running Automatically at Startup
To have your favorite script start every time you log into Windows:
Press Windows Key + R on your keyboard.
Type shell:startup and press Enter.
Create a shortcut of your desired .ahk file.
Drag and drop that shortcut into the folder window that just opened.

📋 Project Examples

Borderless Full-Screen Enforcer
A high-performance script that monitors targeted applications (like Android emulators or media players) and strips away window borders and taskbars to provide a true, immersive full-screen experience.

Example: Transforming a standard window into a native-feeling full-screen application.
Native-Style Network Meter
An OS-aware widget that injects a real-time download/upload tracker directly into the Windows Taskbar. It dynamically repositions itself based on your Windows version and available tray space.

Example: A custom widget injected into the Taskbar, displaying real-time traffic.

🛡 Safety & Customization

Safety Nets: All scripts include an OnExit safety routine. If you close a script, it will automatically restore hidden taskbars or default window styles to ensure your Windows environment remains stable.

Customization: Feel free to open these files in any text editor (Notepad, VS Code) to tweak the TargetApp variables or adjust font sizes and colors to match your personal theme.

⚖️ License

This repository is provided for educational and personal use. Feel free to fork, modify, and improve these scripts to suit your workflow.

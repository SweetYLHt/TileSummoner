#!/usr/bin/env osascript

on run
    tell application "Godot"
        activate
        delay 2
        tell application "System Events"
            keystroke "F5" using {command down}
        end tell
    end tell
    return "Godot 已启动并运行测试"
end run

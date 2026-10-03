Since you have to have the Inventory Hotkey program running while Warcraft III is running, the easiest way to do this is set up a custom hotkey that starts both your game and the hotkey program at the same time.

This can be done by modifying your Warcraft III or Warcraft 3 Champions desktop shortcut.

Here is how to do this in Windows.
- Right-click the shortcut and click "Properties".
- In the "Target" space, copy out one of the following, and paste it in.
- You will have to change "USERNAME" to your actual username.
- If you have installed Warcraft III or W3Champions anywhere but their standard locations, you will have to adjust the file paths as well.

Warcraft III:
C:\Windows\System32\cmd.exe /c start "" /b "C:\Program Files (x86)\Warcraft III\Warcraft III Launcher.exe" & start "" /b "C:\Users\USERNAME\Documents\Warcraft III\CustomKeyBindings\WIH.v1.1.2.w3c.exe"

W3Champions:
C:\Windows\System32\cmd.exe /c start "" /b "C:\Program Files\W3Champions\W3Champions.exe" & start "" /b "C:\Users\USERNAME\Documents\Warcraft III\CustomKeyBindings\WIH.v1.1.2.w3c.exe"
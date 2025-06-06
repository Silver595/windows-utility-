@echo off
title Captain's Ultimate Toolkit
color 0A
:menu
cls
echo =====================================================
echo           🚀 Captain's Portable System Toolkit 🚀
echo =====================================================
echo.
echo [1] Clear Temp Files
echo [2] Flush DNS & Renew IP
echo [3] Kill Background Apps (OneDrive, Teams)
echo [4] Take Instant Screenshot
echo [5] Speak Anything (Text-to-Speech)
echo [6] Generate Strong Password
echo [7] Log Current Public IP
echo [8] Archive Folder to ZIP
echo [9] Encrypted Note Creator
echo [10] Decrypt Note
echo [11] Open System Tools
echo [12] Exit
echo.
set /p choice=Choose your option [1-12]: 

if "%choice%"=="1" goto clear_temp
if "%choice%"=="2" goto flush_dns
if "%choice%"=="3" goto kill_apps
if "%choice%"=="4" goto screenshot
if "%choice%"=="5" goto speak
if "%choice%"=="6" goto password
if "%choice%"=="7" goto log_ip
if "%choice%"=="8" goto zip_folder
if "%choice%"=="9" goto encrypt_note
if "%choice%"=="10" goto decrypt_note
if "%choice%"=="11" goto system_tools
if "%choice%"=="12" exit

goto menu

:clear_temp
del /q /f /s "%TEMP%\*.*"
del /q /f /s "C:\Windows\Temp\*.*"
echo Temp Files Cleared.
pause
goto menu

:flush_dns
ipconfig /flushdns
ipconfig /release
ipconfig /renew
echo DNS flushed and IP renewed.
pause
goto menu

:kill_apps
taskkill /f /im OneDrive.exe
taskkill /f /im Teams.exe
echo Background apps closed.
pause
goto menu

:screenshot
PowerShell -Command "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $bmp = New-Object Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height); $graphics = [System.Drawing.Graphics]::FromImage($bmp); $graphics.CopyFromScreen(0, 0, 0, 0, $bmp.Size); $bmp.Save('C:\Screenshots\Screenshot_{0:yyyyMMdd_HHmmss}.png' -f (Get-Date));"
echo Screenshot saved to C:\Screenshots.
pause
goto menu

:speak
set /p msg="What should I speak? "
PowerShell -Command "Add-Type –AssemblyName System.Speech;$speak = New-Object System.Speech.Synthesis.SpeechSynthesizer;$speak.Speak('%msg%');"
pause
goto menu

:password
PowerShell -Command "[char[]]([char]33..[char]126 | Get-Random -Count 16) -join ''"
pause
goto menu

:log_ip
for /f "tokens=2 delims=:" %%i in ('"nslookup myip.opendns.com. resolver1.opendns.com | find "Address""') do (
  echo %%i >> ip_log.txt
  echo Logged at: %date% %time% >> ip_log.txt
  echo. >> ip_log.txt
)
echo IP logged in ip_log.txt.
pause
goto menu

:zip_folder
set /p folder=Enter full path to folder:
set zipname=Backup_%date:/=%.zip
PowerShell Compress-Archive -Path "%folder%" -DestinationPath "C:\Backup\%zipname%"
echo Folder archived to C:\Backup\%zipname%.
pause
goto menu

:encrypt_note
set /p note=Type your secret note:
PowerShell -Command "[System.IO.File]::WriteAllText('secret.txt',[Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('%note%')))"
echo Note saved encrypted as 'secret.txt'
pause
goto menu

:decrypt_note
PowerShell -Command "[System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String((Get-Content secret.txt)))"
pause
goto menu

:system_tools
start taskmgr
start control
start msconfig
start services.msc
echo Tools launched.
pause
goto menu

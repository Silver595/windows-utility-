@echo off
:: Professional System Administrator Toolkit
:: For authorized use on owned/managed systems only
color 0B
title System Administrator Toolkit v2.0

:main_menu
cls
echo =========================================================
echo           🔧 System Administrator Toolkit 🔧
echo =========================================================
echo.
echo [1]  📊 System Health Overview
echo [2]  💾 Disk Space Analysis
echo [3]  🔄 Process & Memory Monitor
echo [4]  🌡️  CPU & Temperature Info
echo [5]  🔌 Hardware Information
echo [6]  📋 Event Log Summary
echo [7]  🔍 System File Checker
echo [8]  🧹 Disk Cleanup Utility
echo [9]  📈 Performance Baseline
echo [10] 🔒 Security Status Check
echo [11] 🌐 Network Interface Status
echo [12] 📄 Generate System Report
echo [13] 🔄 Windows Updates Status
echo [14] 📦 Installed Programs List
echo [15] ❌ Exit
echo.
set /p choice=Select an option [1-15]: 

if "%choice%"=="1" goto system_health
if "%choice%"=="2" goto disk_analysis
if "%choice%"=="3" goto process_monitor
if "%choice%"=="4" goto cpu_temp
if "%choice%"=="5" goto hardware_info
if "%choice%"=="6" goto event_logs
if "%choice%"=="7" goto system_file_check
if "%choice%"=="8" goto disk_cleanup
if "%choice%"=="9" goto performance_baseline
if "%choice%"=="10" goto security_status
if "%choice%"=="11" goto network_status
if "%choice%"=="12" goto system_report
if "%choice%"=="13" goto update_status
if "%choice%"=="14" goto installed_programs
if "%choice%"=="15" exit
goto main_menu

:system_health
cls
echo Gathering system health information...
echo.
echo === SYSTEM UPTIME ===
systeminfo | findstr /i "boot time"
echo.
echo === CPU USAGE ===
PowerShell -Command "Get-Counter '\Processor(_Total)\% Processor Time' | Select-Object -ExpandProperty CounterSamples | Select-Object CookedValue | ForEach-Object { 'CPU Usage: ' + [math]::Round((100 - $_.CookedValue), 2) + '%' }"
echo.
echo === MEMORY USAGE ===
PowerShell -Command "$mem = Get-CimInstance Win32_OperatingSystem; 'Total RAM: ' + [math]::Round($mem.TotalVisibleMemorySize/1MB, 2) + ' GB'; 'Available RAM: ' + [math]::Round($mem.FreePhysicalMemory/1MB, 2) + ' GB'; 'Used RAM: ' + [math]::Round(($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory)/1MB, 2) + ' GB'"
echo.
pause
goto main_menu

:disk_analysis
cls
echo Analyzing disk usage...
echo.
PowerShell -Command "Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name='Size(GB)';Expression={[math]::Round($_.Used/1GB + $_.Free/1GB, 2)}}, @{Name='Used(GB)';Expression={[math]::Round($_.Used/1GB, 2)}}, @{Name='Free(GB)';Expression={[math]::Round($_.Free/1GB, 2)}}, @{Name='%Free';Expression={[math]::Round(($_.Free/($_.Used + $_.Free)) * 100, 1)}} | Format-Table -AutoSize"
echo.
echo Checking for large files (over 100MB)...
PowerShell -Command "Get-ChildItem C:\ -Recurse -File -ErrorAction SilentlyContinue | Where-Object {$_.Length -gt 100MB} | Sort-Object Length -Descending | Select-Object -First 10 Name, @{Name='Size(MB)';Expression={[math]::Round($_.Length/1MB, 2)}}, FullName | Format-Table -AutoSize"
pause
goto main_menu

:process_monitor
cls
echo Top 10 processes by CPU and Memory usage:
echo.
echo === BY CPU USAGE ===
PowerShell -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, @{Name='Memory(MB)';Expression={[math]::Round($_.WorkingSet/1MB, 2)}} | Format-Table -AutoSize"
echo.
echo === BY MEMORY USAGE ===
PowerShell -Command "Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 10 Name, @{Name='Memory(MB)';Expression={[math]::Round($_.WorkingSet/1MB, 2)}}, CPU | Format-Table -AutoSize"
pause
goto main_menu

:cpu_temp
cls
echo CPU and System Information:
echo.
PowerShell -Command "Get-CimInstance -ClassName Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed, @{Name='Load%';Expression={$_.LoadPercentage}} | Format-List"
echo.
echo Thermal Zone Information (if available):
PowerShell -Command "Get-CimInstance -ClassName MSAcpi_ThermalZoneTemperature -Namespace 'root/wmi' -ErrorAction SilentlyContinue | Select-Object @{Name='Temperature(C)';Expression={($_.CurrentTemperature/10) - 273.15}} | Format-Table -AutoSize"
pause
goto main_menu

:hardware_info
cls
echo Hardware Information Summary:
echo.
echo === MOTHERBOARD ===
PowerShell -Command "Get-CimInstance Win32_BaseBoard | Select-Object Manufacturer, Product | Format-List"
echo.
echo === MEMORY MODULES ===
PowerShell -Command "Get-CimInstance Win32_PhysicalMemory | Select-Object @{Name='Slot';Expression={$_.DeviceLocator}}, @{Name='Size(GB)';Expression={$_.Capacity/1GB}}, Speed, Manufacturer | Format-Table -AutoSize"
echo.
echo === GRAPHICS CARD ===
PowerShell -Command "Get-CimInstance Win32_VideoController | Select-Object Name, @{Name='RAM(MB)';Expression={[math]::Round($_.AdapterRAM/1MB, 0)}} | Format-Table -AutoSize"
pause
goto main_menu

:event_logs
cls
echo Recent Critical and Error Events:
echo.
PowerShell -Command "Get-EventLog -LogName System -EntryType Error,Critical -Newest 10 | Select-Object TimeGenerated, Source, EventID, Message | Format-Table -Wrap"
echo.
echo Recent Application Errors:
PowerShell -Command "Get-EventLog -LogName Application -EntryType Error -Newest 5 | Select-Object TimeGenerated, Source, EventID | Format-Table -AutoSize"
pause
goto main_menu

:system_file_check
cls
echo Running System File Checker...
echo This may take several minutes...
echo.
sfc /scannow
echo.
echo System File Check completed.
pause
goto main_menu

:disk_cleanup
cls
echo Available Disk Cleanup Options:
echo.
echo [1] Run Disk Cleanup Utility
echo [2] Clean Temporary Files
echo [3] Empty Recycle Bin
echo [4] Return to Main Menu
echo.
set /p cleanup_choice=Choose cleanup option [1-4]: 

if "%cleanup_choice%"=="1" cleanmgr
if "%cleanup_choice%"=="2" goto temp_cleanup
if "%cleanup_choice%"=="3" goto empty_recycle
if "%cleanup_choice%"=="4" goto main_menu
goto disk_cleanup

:temp_cleanup
cls
echo Cleaning temporary files...
del /q /f "%temp%\*" 2>nul
del /q /f "C:\Windows\Temp\*" 2>nul
echo Temporary files cleaned.
pause
goto main_menu

:empty_recycle
cls
echo Emptying Recycle Bin...
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo Recycle Bin emptied.
pause
goto main_menu

:performance_baseline
cls
echo Creating Performance Baseline...
echo.
echo Current Performance Metrics:
PowerShell -Command "
Write-Host 'CPU Usage:' (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue '%'
Write-Host 'Available Memory:' ([math]::Round((Get-Counter '\Memory\Available MBytes').CounterSamples.CookedValue, 0)) 'MB'
Write-Host 'Disk Queue Length:' (Get-Counter '\PhysicalDisk(_Total)\Current Disk Queue Length').CounterSamples.CookedValue
Write-Host 'Network Utilization:' (Get-Counter '\Network Interface(*)\Bytes Total/sec' | Measure-Object -Property CounterSamples.CookedValue -Sum).Sum 'bytes/sec'
"
pause
goto main_menu

:security_status
cls
echo Security Status Overview:
echo.
echo === WINDOWS DEFENDER STATUS ===
PowerShell -Command "Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled, BehaviorMonitorEnabled, OnAccessProtectionEnabled | Format-List"
echo.
echo === FIREWALL STATUS ===
netsh advfirewall show allprofiles state
echo.
echo === USER ACCOUNT CONTROL ===
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA
pause
goto main_menu

:network_status
cls
echo Network Interface Status:
echo.
PowerShell -Command "Get-NetAdapter | Select-Object Name, InterfaceDescription, LinkSpeed, Status | Format-Table -AutoSize"
echo.
echo IP Configuration:
PowerShell -Command "Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -ne '127.0.0.1'} | Select-Object InterfaceAlias, IPAddress, PrefixLength | Format-Table -AutoSize"
pause
goto main_menu

:system_report
cls
echo Generating comprehensive system report...
set report_file=%USERPROFILE%\Desktop\SystemReport_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.txt
echo System Report Generated on %date% at %time% > "%report_file%"
echo. >> "%report_file%"
systeminfo >> "%report_file%"
echo. >> "%report_file%"
echo === DISK USAGE === >> "%report_file%"
PowerShell -Command "Get-PSDrive -PSProvider FileSystem | Select-Object Name, @{Name='Used(GB)';Expression={[math]::Round($_.Used/1GB, 2)}}, @{Name='Free(GB)';Expression={[math]::Round($_.Free/1GB, 2)}} | Format-Table" >> "%report_file%"
echo.
echo Report saved to: %report_file%
pause
goto main_menu

:update_status
cls
echo Windows Update Status:
echo.
PowerShell -Command "
if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
    Import-Module PSWindowsUpdate
    Get-WUList | Select-Object Title, Size | Format-Table -AutoSize
} else {
    Write-Host 'PSWindowsUpdate module not available. Checking basic update status...'
    $session = New-Object -ComObject Microsoft.Update.Session
    $searcher = $session.CreateUpdateSearcher()
    $result = $searcher.Search('IsInstalled=0')
    Write-Host 'Available Updates:' $result.Updates.Count
}
"
pause
goto main_menu

:installed_programs
cls
echo Installed Programs List:
echo.
PowerShell -Command "Get-WmiObject -Class Win32_Product | Select-Object Name, Version, Vendor | Sort-Object Name | Format-Table -AutoSize"
pause
goto main_menu
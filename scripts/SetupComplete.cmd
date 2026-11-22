@echo off
:: Golden image - runs once as SYSTEM on each deployed machine at the end of setup.
:: Place at: C:\Windows\Setup\Scripts\SetupComplete.cmd   (ASCII encoding, .cmd extension)

:: --- BitLocker: prevent auto device encryption, and turn off if it started ---
reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v "PreventDeviceEncryption" /t REG_DWORD /d 1 /f
manage-bde -off C: >nul 2>&1

:: --- Accounts ---
net user Administrator /active:yes
net accounts /maxpwage:unlimited
net user "Local User" /logonpasswordchg:yes
net user admin /delete >nul 2>&1

:: --- Computer name: <PREFIX>-<BIOS serial>  (change PREFIX to suit) ---
set "PREFIX=PC"
for /f "usebackq delims=" %%s in (`powershell -NoProfile -Command "(Get-CimInstance -ClassName Win32_BIOS).SerialNumber.Trim()"`) do set "SN=%%s"
if defined SN powershell -NoProfile -Command "Rename-Computer -NewName ($env:PREFIX + '-' + $env:SN) -Force"

:: --- Time zone ---
tzutil /s "Pacific Standard Time"

:: --- Power: screen off 15 min, lock 15 min, AC never sleeps, battery sleeps 30 min ---
powercfg /change monitor-timeout-ac 15
powercfg /change monitor-timeout-dc 15
powercfg /change standby-timeout-ac 0
powercfg /change standby-timeout-dc 30
powercfg /setacvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 900
powercfg /setdcvalueindex SCHEME_CURRENT SUB_VIDEO VIDEOCONLOCK 900
powercfg /setactive SCHEME_CURRENT

:: --- Optional Wi-Fi auto-join ---
if exist C:\Windows\Setup\WiFi\Guest-WiFi.xml netsh wlan add profile filename="C:\Windows\Setup\WiFi\Guest-WiFi.xml" user=all
if exist C:\Windows\Setup\WiFi\Guest-WiFi.xml del /q C:\Windows\Setup\WiFi\Guest-WiFi.xml

:: --- Scrub answer files (they contain the admin password) ---
del /q C:\unattend.xml 2>nul
del /q C:\Windows\Panther\unattend.xml 2>nul
del /q C:\Windows\System32\Sysprep\unattend.xml 2>nul

:: --- Reboot so the new computer name takes effect ---
shutdown /r /t 5 /f

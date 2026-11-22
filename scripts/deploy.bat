@echo off
:: Deploy script - run from WinPE (boot deploy USB -> Shift+F10 -> D:\deploy.bat)
:: WIPES DISK 0, applies install.wim, makes it bootable (UEFI).
setlocal

:: --- Find install.wim on any drive ---
set "WIM="
for %%d in (C D E F G H I J K L M N O P Q R T U V Y Z) do (
    if not defined WIM if exist %%d:\sources\install.wim set "WIM=%%d:\sources\install.wim"
)
if not defined WIM (
    echo ERROR: install.wim not found in \sources\ on any drive.
    exit /b 1
)
echo Found image: %WIM%
echo.

:: --- Show disks and confirm ---
echo list disk > X:\listdisk.txt
diskpart /s X:\listdisk.txt
echo.
echo *** DISK 0 WILL BE COMPLETELY ERASED ***
set /p "OK=Type YES to continue: "
if /i not "%OK%"=="YES" (
    echo Aborted.
    exit /b 1
)

:: --- Partition disk 0 (GPT / UEFI) ---
(
echo select disk 0
echo clean
echo convert gpt
echo create partition efi size=260
echo format quick fs=fat32 label=System
echo assign letter=S
echo create partition msr size=16
echo create partition primary
echo format quick fs=ntfs label=Windows
echo assign letter=W
echo exit
) > X:\partition.txt
diskpart /s X:\partition.txt || (echo ERROR: diskpart failed & exit /b 1)

:: --- Apply image ---
dism /apply-image /imagefile:%WIM% /index:1 /applydir:W:\ || (echo ERROR: DISM apply failed & exit /b 1)

:: --- Make bootable ---
bcdboot W:\Windows /s S: /f UEFI || (echo ERROR: bcdboot failed & exit /b 1)

echo.
echo Deploy complete. Remove the USB. Rebooting in 10 seconds...
timeout /t 10
wpeutil reboot

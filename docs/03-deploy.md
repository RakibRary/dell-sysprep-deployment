# 3. Deploy to Target Laptops

> **Use DISM apply, not the Windows Setup wizard.** The wizard fails on captured images with
> `CRelocateOS ... Error: 0x800700B7`.

## Build a deploy USB

1. Write the Windows 11 ISO to the stick with Rufus (NTFS).
2. Replace `\sources\install.wim` on the stick with your captured `install.wim`.
3. Copy `scripts\deploy.bat` to the root of the stick.

For several sticks, run Rufus on one stick at a time (it won't run twice at once), then copy `install.wim` to all of them in parallel. The copy is the slow part.

## Deploy (automatic)

1. Boot the target from the USB (F12 → USB) → **Shift + F10**.
2. Find the USB letter (`diskpart` → `list volume` → `exit`), then run, for example:

   ```cmd
   D:\deploy.bat
   ```

   The script finds `install.wim`, asks you to type `YES` before wiping **disk 0**, then applies the image and makes it bootable.

## Deploy (manual)

```cmd
diskpart
list disk
select disk 0
clean
convert gpt
create partition efi size=260
format quick fs=fat32 label=System
assign letter=S
create partition msr size=16
create partition primary
format quick fs=ntfs label=Windows
assign letter=W
exit

dism /apply-image /imagefile:D:\sources\install.wim /index:1 /applydir:W:\
bcdboot W:\Windows /s S: /f UEFI
wpeutil reboot
```

If `/index:1` errors, check the index number with `dism /get-imageinfo /imagefile:D:\sources\install.wim`.

## Check the first deployed unit

Log in as Administrator and run:

```cmd
hostname                    :: should be PC-<serial>
net accounts                :: Maximum password age: Unlimited
manage-bde -status C:       :: Fully Decrypted
net user "Local User"         :: exists, password change required
dir C:\Windows\Panther\unattend.xml   :: should NOT exist (scrubbed)
```

Also check Device Manager (no warning icons), Wi-Fi, and the power settings.

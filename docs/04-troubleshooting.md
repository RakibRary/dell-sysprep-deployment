# 4. Troubleshooting

## Sysprep fails: "was installed for a user, but not provisioned for all users"

A Store (Appx) app is blocking it. Known offenders: `aimgr`, Photoshop Express, and anything the Store updated in the background.

1. Find the package name in `C:\Windows\System32\Sysprep\Panther\setupact.log` (search for `SYSPRP Package`).
2. Remove it:

   ```powershell
   Get-AppxPackage -AllUsers *PackageName* | Remove-AppxPackage -AllUsers
   Get-AppxProvisionedPackage -Online | ? DisplayName -like *PackageName* | Remove-AppxProvisionedPackage -Online
   ```

3. Run Sysprep again. Keeping Wi-Fi off during the build stops new packages from turning up.

## Sysprep fails: BitLocker

`manage-bde -status C:` shows encryption on, or **Waiting for Activation**. Run `manage-bde -off C:`, wait for **Fully Decrypted**, then seal.
Deployed units are covered separately: `SetupComplete.cmd` sets `PreventDeviceEncryption=1`.

## Deploy with the Setup wizard fails (0x800700B7)

`setuperr.log` shows `CRelocateOS: Cannot move path ... Error: 0x800700B7` and `BCD: Failed to add system store`.
The fix is to deploy with DISM apply instead ([03-deploy.md](03-deploy.md)).

To find the setup logs from WinPE (Shift + F10):

```cmd
notepad X:\windows\panther\setuperr.log
notepad C:\windows\panther\setuperr.log
notepad C:\$WINDOWS.~BT\Sources\Panther\setuperr.log
```

## Computer comes up as DESKTOP-XXXX, not PC-serial

- Don't put a `<ComputerName>` element in `unattend.xml`. The rename happens in `SetupComplete.cmd`.
- Make sure `SetupComplete.cmd` is at `C:\Windows\Setup\Scripts\` and isn't really named `SetupComplete.cmd.txt`.
- Make sure you captured **after** fixing the master. Deploying an older WIM gives you the old result.

## DISM capture: Error 3 (path not found)

There's a typo in a path, usually `/capturedir:C\` with the colon missing.

## Wrong USB letter

In WinPE, choose the volume by **label and size**. Rufus sticks have a large NTFS data partition and a tiny `RUFUS_BOOT` partition. Use the large one.

## Storage drive not visible during Windows install (Intel)

Use **Load Driver** to load the Intel VMD/RST driver from the driver pack.

## Accidentally booted the sealed master into Windows

The seal is broken. Finish OOBE or go back to Audit Mode (Ctrl+Shift+F3), then run Sysprep again before capturing.

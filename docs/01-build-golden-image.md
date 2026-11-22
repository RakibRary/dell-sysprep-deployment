# 1. Build the Golden Image (Reference Machine)

## What you need

- Reference Dell, the same model you'll deploy to. It will be wiped.
- Windows 11 install USB made with Rufus (GPT / UEFI, NTFS).
- Drivers for the model, as **extracted `.inf` folders**. Dell `.exe` installers have to be extracted first (see below).
- `config/unattend.xml` and `scripts/SetupComplete.cmd` from this repo.
- A **64 GB+ NTFS** USB for the capture. The WIM will be over 4 GB, so FAT32 won't work.

> Images are model-specific. This image was built with AMD Chipset, AMD Radeon,
> Realtek Wi-Fi/BT and Realtek Audio drivers for the PV14255. Rebuild for other models.

---

## Phase 1: Install Windows and enter Audit Mode

1. Boot the reference Dell from the install USB (F12 → UEFI USB).
2. If the SSD doesn't show up at the partition screen, use **Load Driver** to load the Intel VMD/RST storage driver (Intel models).
3. Delete all partitions on the internal SSD → install to the unallocated space.
4. At the **first region screen**, don't click anything. Press **Ctrl + Shift + F3** (on some Dells, **Ctrl + Shift + Fn + F3**).
5. It reboots into **Audit Mode**: you're logged in as Administrator and a Sysprep window is open. Close the Sysprep window.
6. **Turn Wi-Fi off now** and leave it off for the rest of the build.

## Phase 2: Drivers

Extract any Dell `.exe` driver packages to folders, then from an admin Command Prompt:

```cmd
pnputil /add-driver C:\Drivers\*.inf /subdirs /install
```

Check Device Manager. No yellow warning icons means you're good.

## Phase 3: Apps (optional)

Install without signing in to anything, and uncheck bundled extras (McAfee).

- Office (M365) with the Office Deployment Tool: `setup.exe /configure configuration-Office365-x64.xml`
- Zoom, 8x8, Adobe and so on: run the installers.
- **RMM agents (Atera etc.):** don't bake them in unless you follow the vendor's golden-image procedure.
  Otherwise every clone gets the same agent ID and they show up as one device. It's safer to push the agent after deployment.

Remove bloat and anything Sysprep is known to choke on:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\remove-appx-blockers.ps1
```

## Phase 4: Stage the files

| File | Location on reference machine |
|---|---|
| `unattend.xml` (with the real admin password) | `C:\Windows\System32\Sysprep\unattend.xml` |
| `SetupComplete.cmd` | `C:\Windows\Setup\Scripts\SetupComplete.cmd` (create `Scripts`) |
| Wi-Fi profile (optional) | `C:\Windows\Setup\WiFi\Guest-WiFi.xml` |

Turn on **View → Show → File name extensions** in Explorer and make sure nothing got saved as `.xml.txt` or `.cmd.txt`.

## Phase 5: BitLocker must be off on the master

Sysprep fails if BitLocker is on, including the "Waiting for Activation" state.

```cmd
manage-bde -status C:
manage-bde -off C:
```

Keep re-checking until it says **Fully Decrypted / Protection Off**.

## Phase 6: Seal

```cmd
del C:\Windows\System32\utilman.exe.bak 2>nul
cd C:\Windows\System32\Sysprep
sysprep /generalize /oobe /shutdown /unattend:unattend.xml
```

The machine powers off. **Don't let it boot back into Windows.** That starts OOBE and breaks the seal.
Go on to [02-capture.md](02-capture.md).

If Sysprep errors, see [04-troubleshooting.md](04-troubleshooting.md).

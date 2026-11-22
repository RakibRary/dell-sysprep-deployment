<img width="2400" height="1410" alt="image" src="https://github.com/user-attachments/assets/b1659d64-db46-4949-82af-bfe6429d7abc" />


# Windows Golden Image — Dell Sysprep / DISM Deployment

Build a sysprepped Windows 11 "golden image" on a reference Dell, capture it to
`install.wim`, and deploy it to a fleet of identical laptops from USB using DISM.

Proven on: **Dell Pro 14 Essential (PV14255, AMD)**, Windows 11.

## What a deployed machine gets

| Setting | How |
|---|---|
| Computer name `PC-<BIOS serial>` | `SetupComplete.cmd` (Rename-Computer) |
| Built-in **Administrator** enabled, password set | `unattend.xml` + `SetupComplete.cmd` |
| Standard user **Local User** — blank password, must set one at first logon | `unattend.xml` + `SetupComplete.cmd` |
| Passwords never expire (`maxpwage:unlimited`) | `SetupComplete.cmd` |
| BitLocker auto-encryption disabled | `SetupComplete.cmd` |
| Pacific time zone, en-US locale | `unattend.xml` |
| Screen off 15 min, lock 15 min, AC never sleeps, battery sleeps 30 min | `SetupComplete.cmd` |
| Optional Wi-Fi auto-join | `SetupComplete.cmd` + staged WLAN profile |
| OOBE screens skipped | `unattend.xml` |
| Credentials scrubbed from disk after setup | `SetupComplete.cmd` |

## Repo layout

```
docs/
  01-build-golden-image.md   Build the reference machine (Audit Mode → Sysprep)
  02-capture.md              Capture to install.wim with DISM
  03-deploy.md               Build deploy USBs and apply with DISM
  04-troubleshooting.md      Every error hit so far and the fix
config/
  unattend.xml               Answer file (EDIT the password placeholder)
  wifi-profile.example.xml   Template WLAN profile (optional)
scripts/
  SetupComplete.cmd          Runs once on each deployed machine
  remove-appx-blockers.ps1   Removes Store apps that make Sysprep fail
  deploy.bat                 WinPE script: wipe disk 0, apply image, make bootable
```

## Quick start

1. Read [docs/01-build-golden-image.md](docs/01-build-golden-image.md) and build the reference machine.
2. Replace `CHANGE_ME_ADMIN_PASSWORD` in `config/unattend.xml` **on the USB copy only**. Never commit the real password.
3. Seal with Sysprep → capture ([02](docs/02-capture.md)) → deploy ([03](docs/03-deploy.md)).

## The three rules that save the most pain

1. **Wi-Fi OFF during the build.** Store apps that update in the background are the #1 cause of Sysprep failures.
2. **Deploy with DISM apply, never the Windows Setup wizard.** The wizard fails on captured images with `0x800700B7`.
3. **Pick drives by label and size, not letter.** Letters move around in WinPE between boots.

## Security notes

- `unattend.xml` stores the admin password in plain text, or base64 at best. `SetupComplete.cmd` deletes every copy after setup. Keep that step.
- Don't commit real passwords, Wi-Fi keys or `install.wim` files. `.gitignore` blocks the usual ones.
- If a real password ever lands in a commit, change it everywhere. Deleting the file doesn't take it out of git history.

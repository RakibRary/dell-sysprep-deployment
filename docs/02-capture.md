# 2. Capture the Image to install.wim

1. Plug the **64 GB NTFS Rufus USB** into the sealed master.
2. Power on → **F12** → choose the **USB** entry.
   **Don't** choose "Windows Boot Manager". That boots the sealed install and breaks the seal.
3. When Windows Setup loads, **don't click Next**. Press **Shift + F10**.
4. Find the drives:

   ```cmd
   diskpart
   list volume
   exit
   ```

   - **Source:** the large NTFS volume labeled `OS` (usually `C:`).
   - **Target:** the large NTFS **removable** volume (Rufus labels it after the ISO, for example `CCCOMA_X64F`).
     Ignore the 1 MB `RUFUS_BOOT` FAT partition, and never use `X:` (that's the WinPE RAM drive).

5. Check the source (run this at the normal prompt, not inside diskpart):

   ```cmd
   dir C:\
   ```

   You should see `Windows`, `Users` and `Program Files`.

6. Capture (swap in your real letters):

   ```cmd
   dism /capture-image /imagefile:D:\install.wim /capturedir:C:\ /name:"PV14255 Golden" /compress:max
   ```

   - Watch the colon in `/capturedir:C:\`. Leaving it off gives **Error 3**.
   - Type the quotes yourself. Quotes pasted from elsewhere can come through as curly quotes, which break the command.
   - At `/compress:max` this takes roughly 10–25 minutes and the percentage can stall for a while. Leave the lid open and the charger plugged in.

7. Check the result:

   ```cmd
   dir D:\install.wim
   ```

   You want **"The operation completed successfully"** and a file of several GB (8–15 GB is typical).
   A failed capture leaves a partial WIM. Delete it and capture again. The seal on `C:` isn't affected.

> The `MININT-XXXXXXX` computer name you see in WinPE belongs to WinPE itself, not the image.

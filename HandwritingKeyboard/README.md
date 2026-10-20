# Handwriting Keyboard ✍️

An iPad keyboard where you **write with your Apple Pencil (or finger)** and paste your real handwriting as a picture — in Messages, Notes, Mail, and more.

## How it works

1. Switch to the **Handwriting** keyboard (🌐 globe key)
2. Write on the white pad
3. Tap **Copy**
4. Long-press the text box → **Paste**

Keyboard tools: 4 ink colors, Thin/Thick pen, Undo, Clear, Delete.

> Why copy + paste? Apple only lets keyboards type *text*. Pictures have to go through the clipboard.

## Install it on your iPad (one time)

**You need:** your Mac, your iPad, a USB cable, and a free Apple ID.

1. **Get Xcode** — free from the Mac App Store (it's big, takes a while)
2. **Download this folder** to your Mac
3. **Open** `HandwritingKeyboard.xcodeproj` (double-click)
4. **Sign in:** Xcode menu › Settings › Accounts › **+** › Apple ID
5. **Pick your team** (do this twice):
   - Click the blue **HandwritingKeyboard** icon at the top of the left sidebar
   - Under **Targets**, click **HandwritingKeyboard** › **Signing & Capabilities** › Team → choose your name
   - Click **HandwritingKeyboardExtension** › same thing
6. **Plug in your iPad** and tap **Trust** on the iPad
7. At the top of Xcode, choose your iPad from the device list, then press ▶️ (Run)
8. On the iPad, if it says “Untrusted Developer”:
   Settings › General › VPN & Device Management › your Apple ID › **Trust**
9. **Turn on Developer Mode** if asked: Settings › Privacy & Security › Developer Mode

## Turn on the keyboard

1. Settings › General › Keyboard › Keyboards › **Add New Keyboard…** › **Handwriting**
2. Tap **Handwriting** › switch on **Allow Full Access** (needed for Copy)

## Good to know

- **Free Apple ID:** the app stops opening after **7 days** — just plug in and press ▶️ again. A paid Apple Developer account ($99/yr) makes it last a year.
- **On your Mac:** Macs don't allow custom keyboards. But on an Apple-silicon Mac (M1 or newer) you can run the app itself (choose **My Mac (Designed for iPad)** in Xcode) and use its practice pad → Copy → Paste.
- **Bundle ID taken?** If Xcode says the ID is unavailable, change `vitalmindstherapy` to anything else in both targets' Bundle Identifier (keep `.keyboard` on the end for the extension).

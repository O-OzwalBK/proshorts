# pro_shorts

A new Flutter project.

## Prerequisites

This project uses **FVM (Flutter Version Manager)** to manage Flutter SDK versions. All team members must use the same Flutter version to ensure consistency.

### Required Flutter Version
- **Flutter 3.10.0** (Dart 3.0.0)

## Setup Instructions

### 1. Install FVM

If you don't have FVM installed, activate it globally using Dart:

```bash
dart pub global activate fvm
```

**For Windows users:** FVM may not be on your PATH after installation. Add it manually:
```powershell
$env:PATH += ";C:\Users\$env:USERNAME\AppData\Local\Pub\Cache\bin"
```

To make this permanent, add `C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin` to your system's PATH environment variable.

### 2. Install Flutter 3.10.0

Run this command in the project root:

```bash
fvm install 3.10.0
```

### 3. Configure the Project

Set Flutter 3.10.0 as the default for this project:

```bash
fvm use 3.10.0
```

This creates `.fvm/fvm_config.json` which pins the project to the correct Flutter version.

### 4. IDE Configuration

#### **VS Code**
VS Code is automatically configured via `.vscode/settings.json`. The SDK path is set to `.fvm/flutter_sdk`.

If you need to manually configure:
- Open VS Code Settings (Ctrl+,)
- Search for "dart.flutterSdkPath"
- Set the value to: `<project-root>/.fvm/flutter_sdk`

#### **Android Studio / IntelliJ**
1. Open **Preferences** → **Languages & Frameworks** → **Flutter**
2. Set the Flutter SDK path to: `<project-root>/.fvm/flutter_sdk`
3. Click **Apply** and restart the IDE

### 5. Using Flutter Commands

All Flutter commands should be run through FVM to ensure you're using the correct version:

```bash
fvm flutter pub get
fvm flutter run
fvm flutter build apk
fvm flutter test
```

**Tip:** You can create shell aliases to avoid typing `fvm flutter` every time:
- **PowerShell (Windows):**
  ```powershell
  function flutter { & fvm flutter $args }
  ```
- **Bash/Zsh (macOS/Linux):**
  ```bash
  alias flutter='fvm flutter'
  ```

### Verify Setup

Check that everything is configured correctly:

```bash
fvm list
fvm flutter --version
```

You should see:
```
Flutter 3.10.0 • channel stable
Dart 3.0.0
```

## Getting Started with Development

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## FVM Files

- `.fvm/fvm_config.json` - Project Flutter version configuration (tracked in git)
- `.fvm/flutter_sdk/` - Local Flutter SDK folder (ignored in git)

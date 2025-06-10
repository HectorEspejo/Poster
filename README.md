# Poster for macOS

A lightweight, memory-efficient clipboard manager for macOS Silicon with system tray integration and keyboard shortcuts.

## Features

- **System Tray Icon**: Always accessible from the menu bar
- **Clipboard History**: Stores up to 100 recent clipboard items
- **Global Shortcuts**: 
  - `Cmd+Shift+H`: Show clipboard history window
  - `Cmd+Shift+K`: Clear clipboard history
- **Multiple Content Types**: Supports text, images, and files
- **Memory Efficient**: Limits item size to 1MB and history to 100 items
- **Search**: Quickly find items in your clipboard history
- **Launch at Login**: Optional auto-start with macOS

## Building

1. Install Xcode Command Line Tools:
```bash
xcode-select --install
```

2. Build the application:
```bash
cd Poster
swift build -c release
```

3. The executable will be located at `.build/release/Poster`

## Running

To run the application:
```bash
.build/release/Poster
```

The app will appear in your menu bar.

## Creating an App Bundle

To create a proper macOS app bundle:

1. Create the app structure:
```bash
mkdir -p Poster.app/Contents/MacOS
mkdir -p Poster.app/Contents/Resources
```

2. Copy the executable:
```bash
cp .build/release/Poster Poster.app/Contents/MacOS/
```

3. Copy the Info.plist:
```bash
cp Info.plist Poster.app/Contents/
```

4. Now you can drag `Poster.app` to your Applications folder.

## Usage

- Click the clipboard icon in the menu bar to see recent items
- Double-click an item in the history window to paste it
- Use keyboard shortcuts for quick access
- Access preferences to customize shortcuts and settings

## Privacy & Security

This app requires accessibility permissions to:
- Monitor clipboard changes
- Simulate paste operations

You'll be prompted to grant these permissions on first run.
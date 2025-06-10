import Cocoa
import KeyboardShortcuts

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var clipboardManager: ClipboardManager!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        clipboardManager = ClipboardManager()
        setupStatusBar()
        setupShortcuts()
        clipboardManager.startMonitoring()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Poster")
        }
        
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }
    
    private func setupShortcuts() {
        KeyboardShortcuts.onKeyUp(for: .showClipboardHistory) { [weak self] in
            self?.showClipboardHistory()
        }
        
        KeyboardShortcuts.onKeyUp(for: .clearHistory) { [weak self] in
            self?.clipboardManager.clearHistory()
        }
    }
    
    @objc private func showClipboardHistory() {
        guard let window = ClipboardHistoryWindow(clipboardManager: clipboardManager) else { return }
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func showPreferences() {
        let preferencesWindow = PreferencesWindow()
        preferencesWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(nil)
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        
        let history = clipboardManager.getHistory()
        
        if history.isEmpty {
            let emptyItem = NSMenuItem(title: "No items in history", action: nil, keyEquivalent: "")
            emptyItem.isEnabled = false
            menu.addItem(emptyItem)
        } else {
            for (index, item) in history.prefix(10).enumerated() {
                let title = item.preview
                let menuItem = NSMenuItem(title: title, action: #selector(pasteHistoryItem(_:)), keyEquivalent: "")
                menuItem.tag = index
                menuItem.target = self
                menu.addItem(menuItem)
            }
        }
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Show All History", action: #selector(showClipboardHistory), keyEquivalent: "h"))
        menu.addItem(NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(showPreferences), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))
    }
    
    @objc private func pasteHistoryItem(_ sender: NSMenuItem) {
        let history = clipboardManager.getHistory()
        guard sender.tag < history.count else { return }
        
        let item = history[sender.tag]
        clipboardManager.pasteItem(item)
    }
    
    
    @objc private func clearHistory() {
        clipboardManager.clearHistory()
    }
}

extension KeyboardShortcuts.Name {
    static let showClipboardHistory = Self("showClipboardHistory", default: .init(.h, modifiers: [.command, .shift]))
    static let clearHistory = Self("clearHistory", default: .init(.k, modifiers: [.command, .shift]))
}
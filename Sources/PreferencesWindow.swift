import Cocoa
import KeyboardShortcuts

class PreferencesWindow: NSWindow {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Poster Preferences"
        self.center()
        
        setupUI()
    }
    
    private func setupUI() {
        let contentView = NSView(frame: self.contentRect(forFrameRect: self.frame))
        
        let titleLabel = NSTextField(labelWithString: "Keyboard Shortcuts")
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        
        let showHistoryLabel = NSTextField(labelWithString: "Show Clipboard History:")
        showHistoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(showHistoryLabel)
        
        let showHistoryRecorder = KeyboardShortcuts.RecorderCocoa(for: .showClipboardHistory)
        showHistoryRecorder.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(showHistoryRecorder)
        
        let clearHistoryLabel = NSTextField(labelWithString: "Clear History:")
        clearHistoryLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clearHistoryLabel)
        
        let clearHistoryRecorder = KeyboardShortcuts.RecorderCocoa(for: .clearHistory)
        clearHistoryRecorder.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(clearHistoryRecorder)
        
        let settingsTitle = NSTextField(labelWithString: "Settings")
        settingsTitle.font = .boldSystemFont(ofSize: 16)
        settingsTitle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(settingsTitle)
        
        let launchAtLoginCheckbox = NSButton(checkboxWithTitle: "Launch at Login", target: self, action: #selector(toggleLaunchAtLogin(_:)))
        launchAtLoginCheckbox.translatesAutoresizingMaskIntoConstraints = false
        launchAtLoginCheckbox.state = LaunchAtLogin.isEnabled ? .on : .off
        contentView.addSubview(launchAtLoginCheckbox)
        
        let maxHistorySizeLabel = NSTextField(labelWithString: "Maximum history items: 100")
        maxHistorySizeLabel.font = .systemFont(ofSize: 12)
        maxHistorySizeLabel.textColor = .secondaryLabelColor
        maxHistorySizeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(maxHistorySizeLabel)
        
        let maxItemSizeLabel = NSTextField(labelWithString: "Maximum item size: 1 MB")
        maxItemSizeLabel.font = .systemFont(ofSize: 12)
        maxItemSizeLabel.textColor = .secondaryLabelColor
        maxItemSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(maxItemSizeLabel)
        
        let okButton = NSButton(title: "OK", target: self, action: #selector(closeWindow))
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.keyEquivalent = "\r"
        contentView.addSubview(okButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            showHistoryLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 15),
            showHistoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            showHistoryLabel.widthAnchor.constraint(equalToConstant: 160),
            
            showHistoryRecorder.centerYAnchor.constraint(equalTo: showHistoryLabel.centerYAnchor),
            showHistoryRecorder.leadingAnchor.constraint(equalTo: showHistoryLabel.trailingAnchor, constant: 10),
            showHistoryRecorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            clearHistoryLabel.topAnchor.constraint(equalTo: showHistoryLabel.bottomAnchor, constant: 15),
            clearHistoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            clearHistoryLabel.widthAnchor.constraint(equalToConstant: 160),
            
            clearHistoryRecorder.centerYAnchor.constraint(equalTo: clearHistoryLabel.centerYAnchor),
            clearHistoryRecorder.leadingAnchor.constraint(equalTo: clearHistoryLabel.trailingAnchor, constant: 10),
            clearHistoryRecorder.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            settingsTitle.topAnchor.constraint(equalTo: clearHistoryLabel.bottomAnchor, constant: 30),
            settingsTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            launchAtLoginCheckbox.topAnchor.constraint(equalTo: settingsTitle.bottomAnchor, constant: 15),
            launchAtLoginCheckbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            maxHistorySizeLabel.topAnchor.constraint(equalTo: launchAtLoginCheckbox.bottomAnchor, constant: 15),
            maxHistorySizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            maxItemSizeLabel.topAnchor.constraint(equalTo: maxHistorySizeLabel.bottomAnchor, constant: 5),
            maxItemSizeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            
            okButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            okButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            okButton.widthAnchor.constraint(equalToConstant: 80)
        ])
        
        self.contentView = contentView
    }
    
    @objc private func toggleLaunchAtLogin(_ sender: NSButton) {
        LaunchAtLogin.isEnabled = sender.state == .on
    }
    
    @objc private func closeWindow() {
        self.close()
    }
}

struct LaunchAtLogin {
    static var isEnabled: Bool {
        get {
            let launchAgentsPath = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/LaunchAgents")
            let plistPath = launchAgentsPath.appendingPathComponent("com.example.Poster.plist")
            return FileManager.default.fileExists(atPath: plistPath.path)
        }
        set {
            let launchAgentsPath = FileManager.default.homeDirectoryForCurrentUser
                .appendingPathComponent("Library/LaunchAgents")
            let plistPath = launchAgentsPath.appendingPathComponent("com.example.Poster.plist")
            
            if newValue {
                // Create LaunchAgents directory if it doesn't exist
                try? FileManager.default.createDirectory(at: launchAgentsPath, withIntermediateDirectories: true)
                
                // Get the executable path
                let executablePath = Bundle.main.executablePath ?? ProcessInfo.processInfo.arguments[0]
                
                // Create launch agent plist
                let plist: [String: Any] = [
                    "Label": "com.example.Poster",
                    "ProgramArguments": [executablePath],
                    "RunAtLoad": true,
                    "KeepAlive": false
                ]
                
                do {
                    let data = try PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
                    try data.write(to: plistPath)
                } catch {
                    print("Failed to enable launch at login: \(error)")
                }
            } else {
                // Remove launch agent plist
                try? FileManager.default.removeItem(at: plistPath)
            }
        }
    }
}
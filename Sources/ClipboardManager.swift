import Cocoa

class ClipboardManager {
    private var history: [ClipboardItem] = []
    private var timer: Timer?
    private let maxHistorySize = 100
    private let maxItemSizeKB = 1024
    private var lastChangeCount: Int = 0
    
    init() {
        loadHistory()
    }
    
    func startMonitoring() {
        lastChangeCount = NSPasteboard.general.changeCount
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        let currentChangeCount = pasteboard.changeCount
        
        guard currentChangeCount != lastChangeCount else { return }
        lastChangeCount = currentChangeCount
        
        if let string = pasteboard.string(forType: .string) {
            addStringItem(string)
        } else if let image = NSImage(pasteboard: pasteboard) {
            addImageItem(image)
        } else if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) as? [URL] {
            addFileItem(fileURLs)
        }
    }
    
    private func addStringItem(_ string: String) {
        let sizeKB = Double(string.utf8.count) / 1024.0
        guard sizeKB <= Double(maxItemSizeKB) else { return }
        
        let item = ClipboardItem(type: .text, content: string, timestamp: Date())
        addToHistory(item)
    }
    
    private func addImageItem(_ image: NSImage) {
        guard let tiffData = image.tiffRepresentation,
              Double(tiffData.count) / 1024.0 <= Double(maxItemSizeKB) else { return }
        
        let item = ClipboardItem(type: .image, content: image, timestamp: Date())
        addToHistory(item)
    }
    
    private func addFileItem(_ urls: [URL]) {
        let paths = urls.map { $0.path }.joined(separator: "\n")
        let item = ClipboardItem(type: .file, content: paths, timestamp: Date())
        addToHistory(item)
    }
    
    private func addToHistory(_ item: ClipboardItem) {
        history.removeAll { $0.isEqual(to: item) }
        
        history.insert(item, at: 0)
        
        if history.count > maxHistorySize {
            history = Array(history.prefix(maxHistorySize))
        }
        
        saveHistory()
    }
    
    func getHistory() -> [ClipboardItem] {
        return history
    }
    
    func pasteItem(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch item.type {
        case .text:
            if let text = item.content as? String {
                pasteboard.setString(text, forType: .string)
            }
        case .image:
            if let image = item.content as? NSImage {
                pasteboard.writeObjects([image])
            }
        case .file:
            if let paths = item.content as? String {
                let urls = paths.split(separator: "\n").compactMap { URL(fileURLWithPath: String($0)) }
                pasteboard.writeObjects(urls as [NSPasteboardWriting])
            }
        }
        
        simulatePaste()
    }
    
    private func simulatePaste() {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        
        keyDown?.flags = .maskCommand
        keyUp?.flags = .maskCommand
        
        keyDown?.post(tap: .cghidEventTap)
        keyUp?.post(tap: .cghidEventTap)
    }
    
    func clearHistory() {
        history.removeAll()
        saveHistory()
    }
    
    private func saveHistory() {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        
        do {
            let data = try encoder.encode(history.compactMap { $0.toStorable() })
            let url = getHistoryURL()
            try data.write(to: url)
        } catch {
            print("Failed to save history: \(error)")
        }
    }
    
    private func loadHistory() {
        let url = getHistoryURL()
        
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            let storableItems = try decoder.decode([StorableClipboardItem].self, from: data)
            history = storableItems.compactMap { ClipboardItem(from: $0) }
        } catch {
            print("Failed to load history: \(error)")
        }
    }
    
    private func getHistoryURL() -> URL {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = appSupport.appendingPathComponent("Poster", isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: appDir.path) {
            try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        
        return appDir.appendingPathComponent("history.plist")
    }
}
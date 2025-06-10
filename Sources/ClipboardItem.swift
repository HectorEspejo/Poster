import Cocoa

enum ClipboardItemType: Int, Codable {
    case text
    case image
    case file
}

class ClipboardItem {
    let type: ClipboardItemType
    let content: Any
    let timestamp: Date
    
    init(type: ClipboardItemType, content: Any, timestamp: Date) {
        self.type = type
        self.content = content
        self.timestamp = timestamp
    }
    
    convenience init?(from storable: StorableClipboardItem) {
        switch storable.type {
        case .text:
            guard let text = storable.textContent else { return nil }
            self.init(type: .text, content: text, timestamp: storable.timestamp)
        case .image:
            guard let imageData = storable.imageData,
                  let image = NSImage(data: imageData) else { return nil }
            self.init(type: .image, content: image, timestamp: storable.timestamp)
        case .file:
            guard let paths = storable.filePaths else { return nil }
            self.init(type: .file, content: paths, timestamp: storable.timestamp)
        }
    }
    
    var preview: String {
        switch type {
        case .text:
            if let text = content as? String {
                let preview = text.trimmingCharacters(in: .whitespacesAndNewlines)
                return String(preview.prefix(50)) + (preview.count > 50 ? "..." : "")
            }
        case .image:
            return "📷 Image"
        case .file:
            if let paths = content as? String {
                let files = paths.split(separator: "\n")
                if files.count == 1 {
                    return "📁 \(URL(fileURLWithPath: String(files[0])).lastPathComponent)"
                } else {
                    return "📁 \(files.count) files"
                }
            }
        }
        return "Unknown"
    }
    
    func isEqual(to other: ClipboardItem) -> Bool {
        guard type == other.type else { return false }
        
        switch type {
        case .text:
            return (content as? String) == (other.content as? String)
        case .image:
            if let image1 = content as? NSImage,
               let image2 = other.content as? NSImage,
               let data1 = image1.tiffRepresentation,
               let data2 = image2.tiffRepresentation {
                return data1 == data2
            }
        case .file:
            return (content as? String) == (other.content as? String)
        }
        
        return false
    }
    
    func toStorable() -> StorableClipboardItem? {
        var storable = StorableClipboardItem(type: type, timestamp: timestamp)
        
        switch type {
        case .text:
            storable.textContent = content as? String
        case .image:
            if let image = content as? NSImage {
                storable.imageData = image.tiffRepresentation
            }
        case .file:
            storable.filePaths = content as? String
        }
        
        return storable
    }
}

struct StorableClipboardItem: Codable {
    let type: ClipboardItemType
    let timestamp: Date
    var textContent: String?
    var imageData: Data?
    var filePaths: String?
}
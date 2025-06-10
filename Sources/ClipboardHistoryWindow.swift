import Cocoa

class ClipboardHistoryWindow: NSWindow {
    private let clipboardManager: ClipboardManager
    private var tableView: NSTableView!
    private var searchField: NSSearchField!
    private var filteredHistory: [ClipboardItem] = []
    
    init?(clipboardManager: ClipboardManager) {
        self.clipboardManager = clipboardManager
        
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        self.title = "Clipboard History"
        self.center()
        
        setupUI()
        updateHistory()
    }
    
    private func setupUI() {
        let contentView = NSView(frame: self.contentRect(forFrameRect: self.frame))
        
        searchField = NSSearchField(frame: .zero)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholderString = "Search clipboard history..."
        searchField.target = self
        searchField.action = #selector(searchFieldChanged(_:))
        contentView.addSubview(searchField)
        
        let scrollView = NSScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        contentView.addSubview(scrollView)
        
        tableView = NSTableView(frame: .zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.doubleAction = #selector(doubleClickedRow)
        tableView.target = self
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("ClipboardItem"))
        column.title = "Clipboard Items"
        tableView.addTableColumn(column)
        tableView.headerView = nil
        
        scrollView.documentView = tableView
        
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            searchField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            searchField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            searchField.heightAnchor.constraint(equalToConstant: 30),
            
            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            scrollView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        self.contentView = contentView
    }
    
    private func updateHistory() {
        let searchText = searchField.stringValue.lowercased()
        let allHistory = clipboardManager.getHistory()
        
        if searchText.isEmpty {
            filteredHistory = allHistory
        } else {
            filteredHistory = allHistory.filter { item in
                item.preview.lowercased().contains(searchText)
            }
        }
        
        tableView.reloadData()
    }
    
    @objc private func searchFieldChanged(_ sender: NSSearchField) {
        updateHistory()
    }
    
    @objc private func doubleClickedRow() {
        let row = tableView.clickedRow
        guard row >= 0 && row < filteredHistory.count else { return }
        
        let item = filteredHistory[row]
        clipboardManager.pasteItem(item)
        self.close()
    }
}

extension ClipboardHistoryWindow: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredHistory.count
    }
}

extension ClipboardHistoryWindow: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard row < filteredHistory.count else { return nil }
        
        let item = filteredHistory[row]
        let cellView = ClipboardItemCellView(frame: NSRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
        cellView.configure(with: item)
        
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
}

class ClipboardItemCellView: NSView {
    private let typeLabel = NSTextField(labelWithString: "")
    private let contentLabel = NSTextField(labelWithString: "")
    private let timestampLabel = NSTextField(labelWithString: "")
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        typeLabel.font = .systemFont(ofSize: 12)
        typeLabel.textColor = .secondaryLabelColor
        
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.lineBreakMode = .byTruncatingTail
        
        timestampLabel.font = .systemFont(ofSize: 11)
        timestampLabel.textColor = .tertiaryLabelColor
        
        addSubview(typeLabel)
        addSubview(contentLabel)
        addSubview(timestampLabel)
        
        typeLabel.translatesAutoresizingMaskIntoConstraints = false
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        timestampLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            typeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            
            contentLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            contentLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            contentLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 2),
            
            timestampLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            timestampLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5)
        ])
    }
    
    func configure(with item: ClipboardItem) {
        switch item.type {
        case .text:
            typeLabel.stringValue = "Text"
        case .image:
            typeLabel.stringValue = "Image"
        case .file:
            typeLabel.stringValue = "File(s)"
        }
        
        contentLabel.stringValue = item.preview
        
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        timestampLabel.stringValue = formatter.localizedString(for: item.timestamp, relativeTo: Date())
    }
}
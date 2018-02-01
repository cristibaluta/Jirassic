//
//  InputsTableViewDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

let kShellCellHeight = CGFloat(50.0)
let kJitCellHeight = CGFloat(50.0)
let kGitCellHeight = CGFloat(50.0)
let kBrowserCellHeight = CGFloat(160.0)

enum InputType {
    case shell
    case jit
    case git
    case browser
}

class InputsTableViewDataSource: NSObject {
    
    fileprivate let tableView: NSTableView
    fileprivate let cells: [InputType] = [.shell, .jit, .git, .browser]
    fileprivate var browserCell: BrowserCell?
    
    init (tableView: NSTableView) {
        self.tableView = tableView

        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: ShellCell.self)), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: JitCell.self)), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: GitCell.self)), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: BrowserCell.self)), bundle: Bundle.main) != nil, "err")
        
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: ShellCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ShellCell.self)))
        }
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: JitCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: JitCell.self)))
        }
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: GitCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: GitCell.self)))
        }
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: BrowserCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: BrowserCell.self)))
        }
    }

    func settingsBrowser() -> SettingsBrowser {
        return browserCell!.settings()
    }
}

extension InputsTableViewDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return cells.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        let inputType = cells[row]
        switch inputType {
        case .shell:
            return kShellCellHeight
        case .jit:
            return kJitCellHeight
        case .git:
            return kGitCellHeight
        case .browser:
            return kBrowserCellHeight
        }
    }
}

extension InputsTableViewDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cell: NSView! = nil
        let outputType = cells[row]
        switch outputType {
        case .shell:
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ShellCell.self)), owner: self)
        case .jit:
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: JitCell.self)), owner: self)
        case .git:
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: GitCell.self)), owner: self)
        case .browser:
            browserCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: BrowserCell.self)), owner: self) as? BrowserCell
            cell = browserCell!
        }
        
        return cell
    }
}


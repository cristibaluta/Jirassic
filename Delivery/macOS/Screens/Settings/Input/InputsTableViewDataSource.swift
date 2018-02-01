//
//  InputsTableViewDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

let kShellCellHeight = CGFloat(30.0)
let kJitCellHeight = CGFloat(30.0)
let kGitCellHeight = CGFloat(30.0)
let kBrowserCellHeight = CGFloat(80.0)

enum InputType {
    case shell
    case jit
    case git
    case browser
}

class InputsTableViewDataSource: NSObject {
    
    fileprivate let tableView: NSTableView
    fileprivate let cells: [InputType] = [.shell, .jit, .git, .browser]
    
    init (tableView: NSTableView) {
        self.tableView = tableView
        
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: JiraTempoCell.self)), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: HookupCell.self)), bundle: Bundle.main) != nil, "err")
        
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: JiraTempoCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: JiraTempoCell.self)))
        }
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: HookupCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: HookupCell.self)))
        }
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
            return kJitCellHeight
        case .browser:
            return kJitCellHeight
        }
    }
}

extension InputsTableViewDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cell: NSView! = nil
        let outputType = cells[row]
        switch outputType {
        case .shell:
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: JiraTempoCell.self)), owner: self)
        case .jit:
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: HookupCell.self)), owner: self)
        case .git:
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: HookupCell.self)), owner: self)
        case .browser:
            cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: HookupCell.self)), owner: self)
        }
        
        return cell
    }
}


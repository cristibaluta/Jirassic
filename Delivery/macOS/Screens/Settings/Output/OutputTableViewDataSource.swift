//
//  OutputTableViewDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

let kJiraTempoCellHeight = CGFloat(180.0)
let kHookupCellHeight = CGFloat(120.0)

enum OutputType {
    case jiraTempo
    case hookup
}

class OutputTableViewDataSource: NSObject {
    
    fileprivate let tableView: NSTableView
    fileprivate let cells: [OutputType] = [.jiraTempo, .hookup]
    var jiraCell: JiraTempoCell?
    var hookupCell: HookupCell?
    
    init (tableView: NSTableView) {
        self.tableView = tableView
        super.init()
        
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: JiraTempoCell.self)), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: HookupCell.self)), bundle: Bundle.main) != nil, "err")
        
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: JiraTempoCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: JiraTempoCell.self)))
            jiraCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: JiraTempoCell.self)), owner: self) as? JiraTempoCell
        }
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: HookupCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: HookupCell.self)))
            hookupCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: HookupCell.self)), owner: self) as? HookupCell
        }
    }
}

extension OutputTableViewDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return cells.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        let outputType = cells[row]
        switch outputType {
        case .jiraTempo:
            return kJiraTempoCellHeight
        case .hookup:
            return kHookupCellHeight
        }
    }
}

extension OutputTableViewDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var cell: NSView! = nil
        let outputType = cells[row]
        switch outputType {
        case .jiraTempo:
            cell = jiraCell!
        case .hookup:
            cell = hookupCell!
        }
        
        return cell
    }
}

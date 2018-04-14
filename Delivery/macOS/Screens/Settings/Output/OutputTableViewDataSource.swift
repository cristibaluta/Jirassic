//
//  OutputTableViewDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

enum OutputType {
    case jiraTempo
    case cliHookup
    case cocoaHookup
}

class OutputTableViewDataSource: NSObject {
    
    fileprivate let tableView: NSTableView
    fileprivate let cells: [OutputType] = [.jiraTempo, .cliHookup, .cocoaHookup]
    var jiraCell: JiraTempoCell?
    var cliHookupCell: HookupCell?
    var cocoaHookupCell: CocoaHookupCell?
    
    init (tableView: NSTableView) {
        self.tableView = tableView
        super.init()
        
        JiraTempoCell.register(in: tableView)
        HookupCell.register(in: tableView)
        CocoaHookupCell.register(in: tableView)
        
        jiraCell = JiraTempoCell.instantiate(in: self.tableView)
        cliHookupCell = HookupCell.instantiate(in: self.tableView)
        cocoaHookupCell = CocoaHookupCell.instantiate(in: self.tableView)
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
            return JiraTempoCell.height
        case .cliHookup:
            return HookupCell.height
        case .cocoaHookup:
            return CocoaHookupCell.height
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
        case .cliHookup:
            cell = cliHookupCell!
        case .cocoaHookup:
            cell = cocoaHookupCell!
        }
        
        return cell
    }
}

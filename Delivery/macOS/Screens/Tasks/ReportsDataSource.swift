//
//  ReportsDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class ReportsDataSource: NSObject {
    
    fileprivate let tableView: NSTableView
    var reports: [Report] = []
    fileprivate var tempCell: ReportCell?
    
    init (tableView: NSTableView, reports: [Report]) {
        self.tableView = tableView
        self.reports = reports
        
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: ReportCell.self)), bundle: Bundle.main) != nil, "err")
        
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: ReportCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ReportCell.self)))
        }
    }
}

extension ReportsDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return reports.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        guard #available(OSX 10.13, *) else {
            return CGFloat(0)
        }
        let theData = reports[row]
        // Calculate height to fit content
        if tempCell == nil {
            tempCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ReportCell.self)), owner: self) as? ReportCell
            tempCell?.frame = NSRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50)
        }
        ReportCellPresenter(cell: tempCell!).present(theReport: theData)
        
        return tempCell!.heightThatFits
    }
}

extension ReportsDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let theData = reports[row]
        let cell: CellProtocol = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: ReportCell.self)), owner: self) as! ReportCell
        ReportCellPresenter(cell: cell).present(theReport: theData)
        
        return cell as? NSView
    }
}

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
        
        ReportCell.register(in: tableView)
    }
}

extension ReportsDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return reports.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        guard #available(OSX 10.13, *) else {
            // This version of osx supports cell autoresizing
            return CGFloat(0)
        }
        let theData = reports[row]
        // Calculate height to fit content
        if tempCell == nil {
            tempCell = ReportCell.instantiate(in: self.tableView)
            tempCell?.frame = NSRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50)
        }
        ReportCellPresenter(cell: tempCell!).present(theReport: theData)
        
        return tempCell!.heightThatFits
    }
}

extension ReportsDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let theData = reports[row]
        let cell: CellProtocol = ReportCell.instantiate(in: self.tableView)
        ReportCellPresenter(cell: cell).present(theReport: theData)
        
        return cell as? NSView
    }
}

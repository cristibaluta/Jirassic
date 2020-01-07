//
//  ReportsDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class ReportsDataSource: NSObject, TasksAndReportsDataSource {
    
    var tableView: NSTableView! {
        didSet {
            if #available(OSX 10.13, *) {
                tableView.usesAutomaticRowHeights = true
            }
            ReportCell.register(in: tableView)
            CopyReportCell.register(in: tableView)
        }
    }
    var didClickAddRow: ((_ row: Int) -> Void)?
    var didClickRemoveRow: ((_ row: Int) -> Void)?
    var didClickCloseDay: ((_ tasks: [Task]) -> Void)?
    var didClickSaveWorklogs: (() -> Void)?
    var didClickSetupJira: (() -> Void)?
    private var tempCell: ReportCell?
    let numberOfDays: Int
    var reports: [Report]
    
    init (reports: [Report], numberOfDays: Int) {
        self.reports = reports
        self.numberOfDays = numberOfDays
    }
    
    func addTask (_ task: Task, at row: Int) {
        
    }
    
    func removeTask (at row: Int) {
        
    }
}

extension ReportsDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return reports.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        if #available(OSX 10.13, *) {
            // This version of osx supports cell autoresizing
            return CGFloat(50)
        }
        let theData = reports[row]
        // Calculate height to fit content
        if tempCell == nil {
            tempCell = ReportCell.instantiate(in: tableView)
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

//
//  ReportsDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class ReportsDataSource: NSObject, ListDataSource {

    var tableView: NSTableView! {
        didSet {
            if #available(OSX 10.13, *) {
                tableView.usesAutomaticRowHeights = true
            }
            ReportCell.register(in: tableView)
            CopyReportCell.register(in: tableView)
            TaskCell.register(in: tableView)
        }
    }
    var didClickAddRow: ((_ row: Int) -> Void)?
    var didClickRemoveRow: ((_ row: Int) -> Void)?
    var didClickCloseDay: ((_ tasks: [Task]) -> Void)?
    var didClickSaveWorklogs: (() -> Void)?
    var didClickSetupJira: (() -> Void)?
    var didClickCopyReport: ((_ asHtml: Bool) -> Void)?
    var didChangeSettings: (() -> Void)?

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
        return reports.count > 0 ? reports.count + 1 : 0
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        guard row < reports.count else {
            // Doesn't seem to have effect, the cell will be resized based on constrains
            return CGFloat(100)
        }
        if #available(OSX 10.13, *) {
            // This version of osx supports cell autoresizing so it doesn't matter the height
            return CGFloat(50)
        }
        let theData = reports[row]
        // Calculate height to fit content
        if tempCell == nil {
            tempCell = ReportCell.instantiateFromXib()//.instantiate(in: tableView)
            tempCell?.frame = NSRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50)
        }
        ReportCellPresenter(cell: tempCell!).present(theReport: theData)
        
        return tempCell!.heightThatFits
    }
}

extension ReportsDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard row < reports.count else {
            let cell = CopyReportCell.instantiateFromXib()//.instantiate(in: tableView)
            cell.numberOfDays = numberOfDays
            cell.didClickCopyAll = {  [weak self] isHtml in
                self?.didClickCopyReport?(isHtml)
            }
            cell.didChangeSettings = { [weak self] in
                self?.didChangeSettings?()
            }
            return cell
        }

        let theData = reports[row]
        let cell: CellProtocol = ReportCell.instantiateFromXib()//.instantiate(in: tableView)
        ReportCellPresenter(cell: cell).present(theReport: theData)
        
        return cell as? NSView
    }
}

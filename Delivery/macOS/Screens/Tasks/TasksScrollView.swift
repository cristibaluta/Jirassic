//
//  TasksScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import RCPreferences

class TasksScrollView: NSScrollView {
	
    private var tableView: NSTableView!
    private var dataSource: DataSource!
    private var listType: ListType!
    private let pref = RCPreferences<LocalPreferences>()
    
    var didClickAddRow: ((_ row: Int, _ rect: CGRect?) -> Void)?
    var didClickRemoveRow: ((_ row: Int) -> Void)?
    var didClickCloseDay: ((_ tasks: [Task], _ shouldSaveToJira: Bool) -> Void)?
    var didClickSaveWorklogs: (() -> Void)?
    var didClickSetupJira: (() -> Void)?
//    var didClickCopyMonthlyReport: ((_ asHtml: Bool) -> Void)?
//    var didChangeSettings: (() -> Void)?
	
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTableView()
    }
    
    convenience init (dataSource: DataSource, listType: ListType) {
        self.init(frame: NSRect.zero)
        self.setupTableView()
        self.listType = listType
        reloadDataSource(dataSource)
    }
    
    func reloadData() {
        tableView!.reloadData()
    }
    
    func reloadDataSource (_ dataSource: DataSource) {
        self.dataSource = dataSource
        self.dataSource.tableView = tableView
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
        
//        self.dataSource.didClickAddRow = { [weak self] row in
//            self?.didClickAddRow!(row, nil)
//        }
//        self.dataSource.didClickRemoveRow = { [weak self] row in
//            self?.didClickRemoveRow!(row)
//        }
//        self.dataSource.didClickCloseDay = { [weak self] tasks in
//            self?.didClickCloseDay!(tasks, false)
//        }
//        self.dataSource.didClickSaveWorklogs = { [weak self] in
//            self?.didClickSaveWorklogs!()
//        }
//        self.dataSource.didClickSetupJira = { [weak self] in
//            self?.didClickSetupJira!()
//        }
    }
    
    private func setupTableView() {
        
        self.automaticallyAdjustsContentInsets = false
        self.contentInsets = NSEdgeInsetsMake(0, 0, 0, 0)
        self.drawsBackground = false
        self.hasVerticalScroller = true
        
        tableView = NSTableView(frame: self.frame)
        tableView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        tableView.backgroundColor = NSColor.clear
        tableView.headerView = nil
        
        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "taskColumn"))
        column.width = 400
        tableView.addTableColumn(column)
        
        self.documentView = tableView!
	}
    
	func addTask (_ task: Task, at row: Int) {
        if let dataSource = tableView.dataSource as? TasksDataSource {
            dataSource.addTask(task, at: row)
        }
	}
	
    func removeTask (at row: Int) {
        if let dataSource = tableView.dataSource as? TasksDataSource {
            dataSource.removeTask(at: row)
            let rowsToRemoveFromTable = IndexSet(integer: row)
            tableView.removeRows(at: rowsToRemoveFromTable, withAnimation: .effectFade)
        }
	}
    
    func frameOfCell (atRow row: Int) -> NSRect {
        return tableView.frameOfCell(atColumn: 0, row: row)
    }
    
    func view() -> NSTableView {
        return self.tableView
    }
}

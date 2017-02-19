//
//  TasksScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksScrollView: NSScrollView {
	
    fileprivate var tableView: NSTableView!
    fileprivate var dataSource: DataSource?
	
	var didAddRow: ((_ row: Int) -> ())?
	var didRemoveRow: ((_ row: Int) -> ())?
	
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }
    
    convenience init (tasks: [Task]) {
        self.init(frame: NSRect.zero)
        self.setup()
        
        dataSource = TasksDataSource(tableView: tableView, tasks: tasks)
        tableView!.dataSource = dataSource
        tableView!.delegate = dataSource
    }
    
    convenience init (reports: [Report]) {
        self.init(frame: NSRect.zero)
        self.setup()
        
        dataSource = ReportsDataSource(tableView: tableView, reports: reports)
        tableView!.dataSource = dataSource
        tableView!.delegate = dataSource
        
        let headerView = ReportsHeaderView()
        tableView!.headerView = headerView
    }
    
    fileprivate func setup() {        
        
        self.automaticallyAdjustsContentInsets = false
        self.contentInsets = NSEdgeInsetsMake(0, 0, 0, 0)
        self.drawsBackground = false
        self.hasVerticalScroller = true
        
        tableView = NSTableView(frame: self.frame)
        tableView!.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
        tableView!.backgroundColor = NSColor.clear
        tableView!.headerView = nil
        
        let column = NSTableColumn(identifier: "taskColumn")
        column.width = 400
        tableView.addTableColumn(column)
        
        self.documentView = tableView!
//        tableView!.constrainToSuperview()
	}
	
	func reloadData() {
		tableView!.reloadData()
	}
	
	func addTask (_ task: Task) {
        if let dataSource = tableView.dataSource as? TasksDataSource {
            dataSource.addTask(task)
        }
	}
	
    func removeTaskAtRow (_ row: Int) {
        if let dataSource = tableView.dataSource as? TasksDataSource {
            dataSource.removeTaskAtRow(row)
        }
	}
}

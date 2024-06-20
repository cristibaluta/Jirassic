//
//  TasksScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import RCPreferences

class ListView: NSScrollView {

    private var tableView: NSTableView!
    private var dataSource: DataSource!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTableView()
    }

    convenience init (dataSource: DataSource) {
        self.init(frame: NSRect.zero)
        self.setupTableView()
        reloadDataSource(dataSource)
    }

    func reloadData() {
        tableView!.reloadData()
    }

    func reloadFooter() {
        tableView!.reloadData(forRowIndexes: IndexSet(integer: tableView.numberOfRows - 1),
                              columnIndexes: IndexSet(integer: 0))
    }

    func reloadDataSource (_ dataSource: DataSource) {
        self.dataSource = dataSource
        self.dataSource.tableView = tableView
        tableView.dataSource = self.dataSource
        tableView.delegate = self.dataSource
    }

    private func setupTableView() {

        self.automaticallyAdjustsContentInsets = false
        self.contentInsets = NSEdgeInsetsMake(0, 0, 0, 0)
        self.drawsBackground = false
        self.hasVerticalScroller = true

        tableView = NSTableView(frame: self.frame)
        tableView.selectionHighlightStyle = NSTableView.SelectionHighlightStyle.none
        if #available(macOS 11.0, *) {
            tableView.style = .fullWidth
        }
        tableView.backgroundColor = .clear
        tableView.headerView = nil

        let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "taskColumn"))
        column.width = self.frame.size.width
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
}

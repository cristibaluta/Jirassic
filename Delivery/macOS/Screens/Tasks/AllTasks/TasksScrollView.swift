//
//  TasksScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksScrollView: NSScrollView {
	
    private var tableView: NSTableView!
    private var dataSource: DataSource!
    private let localPreferences = RCPreferences<LocalPreferences>()
	
	var didAddRow: ((_ row: Int) -> Void)?
    var didRemoveRow: ((_ row: Int) -> Void)?
    var didChangeSettings: (() -> Void)?
    var didCloseDay: ((_ tasks: [Task], _ shouldSaveToJira: Bool) -> Void)?
	
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
        
        let dataSource = TasksDataSource(tableView: tableView, tasks: tasks)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        dataSource.didAddRow = { [weak self] (row: Int) -> Void in
            self?.didAddRow!(row)
        }
        dataSource.didRemoveRow = { [weak self] (row: Int) -> Void in
            self?.didRemoveRow!(row)
        }
        dataSource.didCloseDay = { [weak self] (tasks: [Task], shouldSaveToJira) -> Void in
            self?.didCloseDay!(tasks, shouldSaveToJira)
        }
        
        // Add header
        
        let headerView = TasksHeaderView.instantiateFromXib()
        headerView.didCloseDay = { [weak self] shouldSaveToJira in
            if let wself = self {
//                wself.didCloseDay!(wself.tasks, shouldSaveToJira)
            }
        }
        headerView.didAddTask = { [weak self] in
            if let wself = self {
//                wself.didAddRow!(wself.tasks.count - 1)
            }
        }
//        headerView.isDayEnded = self.tasks.contains(where: { $0.taskType == .endDay })
        
        tableView.headerView = headerView
        
        self.dataSource = dataSource
    }
    
    convenience init (reports: [Report], numberOfDays: Int, type: ListType) {
        self.init(frame: NSRect.zero)
        self.setup()
        
        let dataSource = ReportsDataSource(tableView: tableView, reports: reports)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        if #available(OSX 10.13, *) {
            tableView!.usesAutomaticRowHeights = true
        }
        
        let settings = SettingsInteractor().getAppSettings()
        let workingDayLength = TimeInteractor(settings: settings).workingDayLength()
        let totalTime = StatisticsInteractor().duration(of: reports)
        
        var headerView: ReportsHeaderView!
        switch type {
        case .report:
            headerView = ReportsHeaderView(height: CGFloat(60))
        case .monthlyReports:
            let monthHeaderView = MonthReportsHeaderView(height: CGFloat(100))
            monthHeaderView.numberOfDays = numberOfDays
            monthHeaderView.didCopyAll = {
                let interactor = CreateMonthReport()
                let joined = interactor.joinReports(reports)
                let string = joined.notes + "\n\n" + joined.totalDuration.secToHoursAndMin
                NSPasteboard.general.clearContents()
                NSPasteboard.general.writeObjects([string as NSPasteboardWriting])
            }
            headerView = monthHeaderView
        default:
            break
        }
        headerView.workdayTime = workingDayLength.secToPercent
        headerView.workedTime = localPreferences.bool(.usePercents)
            ? String(describing: totalTime.secToPercent)
            : totalTime.secToHoursAndMin
        headerView.didChangeSettings = { [weak self] in
            self?.didChangeSettings!()
        }
        tableView.headerView = headerView
        
        self.dataSource = dataSource
    }
    
    private func setup() {
        
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
//        tableView!.constrainToSuperview()
	}
	
	func reloadData() {
		tableView!.reloadData()
	}
    
    func reloadReports (_ reports: [Report]) {
        dataSource = ReportsDataSource(tableView: tableView, reports: reports)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        tableView.reloadData()
    }
	
	func addTask (_ task: Task) {
        if let dataSource = tableView.dataSource as? TasksDataSource {
            dataSource.addTask(task)
        }
	}
	
    func removeTask (at row: Int) {
        if let dataSource = tableView.dataSource as? TasksDataSource {
            dataSource.removeTask(at: row)
            var rowsToRemoveFromTable = IndexSet(integer: row)
            // Remove the last row with buttons when there  is only 1 task,  which means there are 2 rows
            if tableView.numberOfRows == 2 {
                rowsToRemoveFromTable = IndexSet(integersIn: 0...1)
            }
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

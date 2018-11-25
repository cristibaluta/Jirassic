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
    private var listType: ListType!
    private let pref = RCPreferences<LocalPreferences>()
    
	var didClickAddRow: ((_ row: Int) -> Void)?
    var didClickRemoveRow: ((_ row: Int) -> Void)?
    var didClickCloseDay: ((_ tasks: [Task], _ shouldSaveToJira: Bool) -> Void)?
    var didChangeSettings: (() -> Void)?
	
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
        addHeader()
        
        self.dataSource.didClickAddRow = { [weak self] row in
            self?.didClickAddRow!(row)
        }
        self.dataSource.didClickRemoveRow = { [weak self] row in
            self?.didClickRemoveRow!(row)
        }
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
    
    private func addHeader() {
        
        if let dataSource = self.dataSource as? TasksDataSource {
            
            guard dataSource.tasks.count > 0 else {
                tableView.headerView = nil
                return
            }
            guard tableView.headerView == nil else {
                return
            }
            let headerView = TasksHeaderView.instantiateFromXib()
            headerView.didClickCloseDay = { [weak self] in
                self?.didClickCloseDay!(dataSource.tasks, false)
            }
            headerView.didClickAddTask = { [weak self] in
                if let wself = self {
                    wself.didClickAddRow!(wself.dataSource.numberOfRows!(in: wself.tableView) - 1)
                }
            }
            headerView.didClickSaveWorklogs = { [weak self] in
                self?.didClickCloseDay!(dataSource.tasks, true)
            }
            headerView.isDayEnded = dataSource.isDayEnded
            
            tableView.headerView = headerView
        }
        else if let dataSource = self.dataSource as? ReportsDataSource {
            
            guard dataSource.reports.count > 0 else {
                tableView.headerView = nil
                return
            }
            guard tableView.headerView == nil else {
                return
            }
            let settings = SettingsInteractor().getAppSettings()
            let workingDayLength = TimeInteractor(settings: settings).workingDayLength()
            let totalTime = StatisticsInteractor().duration(of: dataSource.reports)
            
            var headerView: ReportsHeaderView!
            switch listType! {
            case .report:
                headerView = ReportsHeaderView(height: CGFloat(60))
            case .monthlyReports:
                let monthHeaderView = MonthReportsHeaderView(height: CGFloat(100))
                monthHeaderView.numberOfDays = dataSource.numberOfDays
                monthHeaderView.didClickCopyAll = {
                    let interactor = CreateMonthReport()
                    let joined = interactor.joinReports(dataSource.reports)
                    let string = joined.notes + "\n\n" + joined.totalDuration.secToHoursAndMin
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.writeObjects([string as NSPasteboardWriting])
                }
                headerView = monthHeaderView
            default:
                break
            }
            headerView.workdayTime = workingDayLength.secToPercent
            headerView.workedTime = pref.bool(.usePercents)
                ? String(describing: totalTime.secToPercent)
                : totalTime.secToHoursAndMin
            headerView.didChangeSettings = { [weak self] in
                self?.didChangeSettings!()
            }
            tableView.headerView = headerView
        }
    }
	
	func addTask (_ task: Task, at row: Int) {
        if let dataSource = tableView.dataSource as? TasksDataSource {
            dataSource.addTask(task, at: row)
            addHeader()
        }
	}
	
    func removeTask (at row: Int) {
        if let dataSource = tableView.dataSource as? TasksDataSource {
            dataSource.removeTask(at: row)
            let rowsToRemoveFromTable = IndexSet(integer: row)
            tableView.removeRows(at: rowsToRemoveFromTable, withAnimation: .effectFade)
            addHeader()
        }
	}
    
    func frameOfCell (atRow row: Int) -> NSRect {
        return tableView.frameOfCell(atColumn: 0, row: row)
    }
    
    func view() -> NSTableView {
        return self.tableView
    }
}

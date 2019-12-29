//
//  TasksDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

let kNonTaskCellHeight = CGFloat(40.0)
let kTaskCellHeight = CGFloat(40.0)
let kCloseDayCellHeight = CGFloat(90.0)
let kGapBetweenCells = CGFloat(16.0)
let kCellLeftPadding = CGFloat(10.0)

class TasksDataSource: NSObject, TasksAndReportsDataSource {
    
    var didClickAddRow: ((_ row: Int) -> Void)?
    var didClickRemoveRow: ((_ row: Int) -> Void)?
    var didClickCloseDay: ((_ tasks: [Task]) -> Void)?
    var didClickSaveWorklogs: (() -> Void)?
    var didClickSetupJira: (() -> Void)?
    
    internal var tableView: NSTableView! {
        didSet {
            TaskCell.register(in: tableView)
            NonTaskCell.register(in: tableView)
            CloseDayCell.register(in: tableView)
            ClosedDayCell.register(in: tableView)
        }
    }
    private var tasks: [Task]
    private var isDayEnded: Bool {
        return self.tasks.contains(where: { $0.taskType == .endDay })
    }
    
    init (tasks: [Task]) {
        self.tasks = tasks
    }
    
    private func cellForTaskType (_ taskType: TaskType) -> CellProtocol {
        
        switch taskType {
        case .issue, .gitCommit:
            return TaskCell.instantiate(in: tableView)
        default:
            return NonTaskCell.instantiate(in: tableView)
        }
    }
    
    func addTask (_ task: Task, at row: Int) {
        tasks.insert(task, at: row)
    }
    
    func removeTask (at row: Int) {
        tasks.remove(at: row)
    }
}

extension TasksDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return tasks.count > 0 ? tasks.count + 1 : 0
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        guard row < tasks.count else {
            return kCloseDayCellHeight
        }
        let theData = tasks[row]
        switch theData.taskType {
        case TaskType.issue, TaskType.gitCommit:
            return kTaskCellHeight
        default:
            return kNonTaskCellHeight
        }
    }
}

extension TasksDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard row < tasks.count else {
            if self.isDayEnded {
                let cell = ClosedDayCell.instantiate(in: tableView)
                cell.didClickSaveWorklogs = {
                    self.didClickSaveWorklogs?()
                }
                cell.didClickSetupJira = {
                    self.didClickSetupJira?()
                }
                return cell
            } else {
                let cell = CloseDayCell.instantiate(in: tableView)
                cell.didClickAddTask = {
                    self.didClickAddRow?(self.tasks.count - 1)
                }
                cell.didClickCloseDay = {
                    self.didClickCloseDay?(self.tasks)
                }
                return cell
            }
        }
        
        var theData = tasks[row]
        let thePreviousData: Task? = row == 0 ? nil : tasks[row-1]
        var cell: CellProtocol = self.cellForTaskType(theData.taskType)
        TaskCellPresenter(cell: cell).present(previousTask: thePreviousData, currentTask: theData)
        
        cell.didEndEditingCell = { [weak self] (cell: CellProtocol) in
            let updatedData = cell.data
            theData.taskNumber = updatedData.taskNumber
            theData.notes = updatedData.notes
            theData.startDate = updatedData.dateStart
            theData.endDate = updatedData.dateEnd
            // Save to local variable
            self?.tasks[row] = theData
            // Save to db and server
            let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
            saveInteractor.saveTask(theData, allowSyncing: true, completion: { savedTask in
                tableView.reloadData(forRowIndexes: [row], columnIndexes: [0])
            })
        }
        cell.didClickRemoveCell = { [weak self] (cell: CellProtocol) in
            // Ugly hack to find the row number from which the action came
            tableView.enumerateAvailableRowViews( { (rowView, rowIndex) -> Void in
                if rowView.subviews.first! == cell as! NSTableRowView {
                    self?.didClickRemoveRow!(rowIndex)
                    return
                }
            })
        }
        cell.didClickAddCell = { [weak self] (cell: CellProtocol) in
            // Ugly hack to find the row number from which the action came
            tableView.enumerateAvailableRowViews( { rowView, rowIndex in
                if rowView.subviews.first! == cell as! NSTableRowView {
                    self?.didClickAddRow!(rowIndex)
                    return
                }
            })
        }
        
        return cell as? NSView
    }
}

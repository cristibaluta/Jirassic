//
//  TasksDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

let kNonTaskCellHeight = CGFloat(40.0)
let kTaskCellHeight = CGFloat(90.0)
let kGapBetweenCells = CGFloat(16.0)
let kCellLeftPadding = CGFloat(10.0)

class TasksDataSource: NSObject, TasksAndReportsDataSource {
    
    var tableView: NSTableView! {
        didSet {
            TaskCell.register(in: tableView)
            NonTaskCell.register(in: tableView)
        }
    }
    var tasks: [Task]
    var didClickAddRow: ((_ row: Int) -> Void)?
    var didClickRemoveRow: ((_ row: Int) -> Void)?
    var isDayEnded: Bool {
        return self.tasks.contains(where: { $0.taskType == .endDay })
    }
    
    init (tasks: [Task]) {
        self.tasks = tasks
    }
    
    private func cellForTaskType (_ taskType: TaskType) -> CellProtocol {
        
        switch taskType {
        case TaskType.issue, TaskType.gitCommit:
            return TaskCell.instantiate(in: self.tableView)
        default:
            return NonTaskCell.instantiate(in: self.tableView)
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
        return tasks.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
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
            tableView.enumerateAvailableRowViews({ (rowView, rowIndex) -> Void in
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

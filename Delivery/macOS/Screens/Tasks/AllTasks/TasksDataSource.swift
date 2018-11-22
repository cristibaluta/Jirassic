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

class TasksDataSource: NSObject {
    
    private let tableView: NSTableView
    private var tasks: [Task] = []
    var didAddRow: ((_ row: Int) -> Void)?
    var didRemoveRow: ((_ row: Int) -> Void)?
    var didCloseDay: ((_ tasks: [Task], _ shouldSaveToJira: Bool) -> Void)?
    
    init (tableView: NSTableView, tasks: [Task]) {
        
        self.tableView = tableView
        self.tasks = tasks
        
        TaskCell.register(in: tableView)
        NonTaskCell.register(in: tableView)
    }
    
    private func cellForTaskType (_ taskType: TaskType) -> CellProtocol {
        
        var cell: CellProtocol? = nil
        switch taskType {
        case TaskType.issue, TaskType.gitCommit:
            cell = TaskCell.instantiate(in: self.tableView)
            break
        default:
            cell = NonTaskCell.instantiate(in: self.tableView)
            break
        }
        
        return cell!
    }
    
    func addTask (_ task: Task) {
        tasks.insert(task, at: 0)
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
            self?.tasks[row] = theData// save the changes locally because the struct is passed by copying
            let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
            saveInteractor.saveTask(theData, allowSyncing: true, completion: { savedTask in
                tableView.reloadData(forRowIndexes: [row], columnIndexes: [0])
            })
        }
        cell.didRemoveCell = { [weak self] (cell: CellProtocol) in
            // Ugly hack to find the row number from which the action came
            tableView.enumerateAvailableRowViews({ (rowView, rowIndex) -> Void in
                if rowView.subviews.first! == cell as! NSTableRowView {
                    self?.didRemoveRow!(rowIndex)
                    return
                }
            })
        }
        cell.didAddCell = { [weak self] (cell: CellProtocol) in
            // Ugly hack to find the row number from which the action came
            tableView.enumerateAvailableRowViews( { rowView, rowIndex in
                if rowView.subviews.first! == cell as! NSTableRowView {
                    self?.didAddRow!(rowIndex)
                    return
                }
            })
        }
        
        return cell as? NSView
    }
}

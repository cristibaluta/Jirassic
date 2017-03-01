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
    
    fileprivate let tableView: NSTableView
    fileprivate var tasks: [Task] = []
    var didAddRow: ((_ row: Int) -> ())?
    var didRemoveRow: ((_ row: Int) -> ())?
    
    init (tableView: NSTableView, tasks: [Task]) {
        self.tableView = tableView
        self.tasks = tasks
        
        assert(NSNib(nibNamed: String(describing: TaskCell.self), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: String(describing: NonTaskCell.self), bundle: Bundle.main) != nil, "err")
        
        if let nib = NSNib(nibNamed: String(describing: TaskCell.self), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: String(describing: TaskCell.self))
        }
        if let nib = NSNib(nibNamed: String(describing: NonTaskCell.self), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: String(describing: NonTaskCell.self))
        }
    }
    
    fileprivate func cellForTaskType (_ taskType: TaskType) -> CellProtocol {
        
        var cell: CellProtocol? = nil
        switch taskType {
        case TaskType.issue, TaskType.gitCommit:
            cell = self.tableView.make(withIdentifier: String(describing: TaskCell.self), owner: self) as? TaskCell
            break
        default:
            cell = self.tableView.make(withIdentifier: String(describing: NonTaskCell.self), owner: self) as? NonTaskCell
            break
        }
        
        return cell!
    }
    
    func addTask (_ task: Task) {
        tasks.insert(task, at: 0)
    }
    
    func removeTaskAtRow (_ row: Int) {
        tasks.remove(at: row)
        tableView.removeRows(at: IndexSet(integer: row), 
                             withAnimation: NSTableViewAnimationOptions.effectFade)
    }
}

extension TasksDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return tasks.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        let theData = tasks[row]
        // Return predefined height
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
        //let thePreviousData: Task? = (row + 1 < tasks!.count) ? tasks![row+1] : nil
        let thePreviousData: Task? = row == 0 ? nil : tasks[row-1]
        var cell: CellProtocol = cellForTaskType(theData.taskType)
        TaskCellPresenter(cell: cell).present(previousTask: thePreviousData, currentTask: theData)
        
        cell.didEndEditingCell = { [weak self] (cell: CellProtocol) in
            let updatedData = cell.data
            theData.taskNumber = updatedData.taskNumber
            theData.notes = updatedData.notes
            theData.startDate = updatedData.dateStart
            theData.endDate = updatedData.dateEnd
            self?.tasks[row] = theData// save the changes locally because the struct is passed by copying
            let saveInteractor = TaskInteractor(repository: localRepository)
            saveInteractor.saveTask(theData)
            tableView.reloadData(forRowIndexes: [row], columnIndexes: [0])
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

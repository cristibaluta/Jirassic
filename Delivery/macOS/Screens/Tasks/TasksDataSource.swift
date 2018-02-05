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
let kEndCellSmallHeight = CGFloat(70.0)
let kEndCellLargeHeight = CGFloat(135.0)
let kGapBetweenCells = CGFloat(16.0)
let kCellLeftPadding = CGFloat(10.0)

class TasksDataSource: NSObject {
    
    fileprivate let tableView: NSTableView
    fileprivate var tasks: [Task] = []
    var didAddRow: ((_ row: Int) -> Void)?
    var didRemoveRow: ((_ row: Int) -> Void)?
    var didEndDay: ((_ tasks: [Task]) -> Void)?
    
    init (tableView: NSTableView, tasks: [Task]) {
        self.tableView = tableView
        self.tasks = tasks
        
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: TaskCell.self)), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: NonTaskCell.self)), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: NSNib.Name(rawValue: String(describing: EndCell.self)), bundle: Bundle.main) != nil, "err")
        
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: TaskCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: TaskCell.self)))
        }
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: NonTaskCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: NonTaskCell.self)))
        }
        if let nib = NSNib(nibNamed: NSNib.Name(rawValue: String(describing: EndCell.self)), bundle: Bundle.main) {
            tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: EndCell.self)))
        }
    }
    
    fileprivate func cellForTaskType (_ taskType: TaskType) -> CellProtocol {
        
        var cell: CellProtocol? = nil
        switch taskType {
        case TaskType.issue, TaskType.gitCommit:
            cell = self.tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: TaskCell.self)), owner: self) as? TaskCell
            break
//        case TaskType.endDay:
//            cell = self.tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: EndCell.self)), owner: self) as? EndCell
//            break
        default:
            cell = self.tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: NonTaskCell.self)), owner: self) as? NonTaskCell
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
                             withAnimation: NSTableView.AnimationOptions.effectFade)
    }
}

extension TasksDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        guard tasks.count > 0 else {
            return 0
        }
        return tasks.count + 1
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        guard row < tasks.count else {
            return kEndCellSmallHeight
        }
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

        guard row < tasks.count else {
            let cell = self.tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: String(describing: EndCell.self)), owner: self) as? EndCell

            cell?.didEndDay = { [weak self] () in
                if let wself = self {
                    wself.didEndDay!(wself.tasks)
                }
            }
            cell?.didAddTask = { [weak self] in
                self?.didAddRow!(tableView.numberOfRows-1)
            }
            return cell
        }

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

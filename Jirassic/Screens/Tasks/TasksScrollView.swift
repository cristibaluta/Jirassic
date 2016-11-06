//
//  TasksScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

let kNonTaskCellHeight = CGFloat(40.0)
let kTaskCellHeight = CGFloat(90.0)

class TasksScrollView: NSScrollView {
	
	@IBOutlet fileprivate var tableView: NSTableView?
    fileprivate var tempCell: ReportCell?
	
    var listType: ListType = ListType.allTasks
    var tasks: [Task]? = []
    var reports: [Report]?
	var didSelectRow: ((_ row: Int) -> ())?
	var didAddRow: ((_ row: Int) -> ())?
	var didRemoveRow: ((_ row: Int) -> ())?
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		tableView?.dataSource = self
		tableView?.delegate = self
		
		assert(NSNib(nibNamed: String(describing: TaskCell.self), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: String(describing: NonTaskCell.self), bundle: Bundle.main) != nil, "err")
        assert(NSNib(nibNamed: String(describing: ReportCell.self), bundle: Bundle.main) != nil, "err")
		
		if let nib = NSNib(nibNamed: String(describing: TaskCell.self), bundle: Bundle.main) {
			tableView?.register(nib, forIdentifier: String(describing: TaskCell.self))
		}
		if let nib = NSNib(nibNamed: String(describing: NonTaskCell.self), bundle: Bundle.main) {
			tableView?.register(nib, forIdentifier: String(describing: NonTaskCell.self))
        }
        if let nib = NSNib(nibNamed: String(describing: ReportCell.self), bundle: Bundle.main) {
            tableView?.register(nib, forIdentifier: String(describing: ReportCell.self))
        }
	}
	
	func reloadData() {
		self.tableView?.reloadData()
	}
	
	func addTask (_ task: Task) {
		tasks?.insert(task, at: 0)
	}
	
    func removeTaskAtRow (_ row: Int) {
		tasks?.remove(at: row)
        self.tableView?.removeRows(at: IndexSet(integer: row), withAnimation: NSTableViewAnimationOptions.effectFade)
	}
    
    fileprivate func cellForTaskType (_ taskType: NSNumber) -> CellProtocol {
        
        var cell: CellProtocol? = nil
        if listType == ListType.report {
            cell = self.tableView?.make(withIdentifier: String(describing: ReportCell.self), owner: self) as? ReportCell
        } else {
            switch Int(taskType.int32Value) {
            case TaskType.issue.rawValue, TaskType.gitCommit.rawValue:
                cell = self.tableView?.make(withIdentifier: String(describing: TaskCell.self), owner: self) as? TaskCell
                break
            default:
                cell = self.tableView?.make(withIdentifier: String(describing: NonTaskCell.self), owner: self) as? NonTaskCell
                break
            }
        }
        guard cell != nil else {
            fatalError("Cell can't be nil, check if the identifier is registered")
        }
        
        return cell!
    }
}

extension TasksScrollView: NSTableViewDataSource {
	
	func numberOfRows (in aTableView: NSTableView) -> Int {
        return listType == ListType.report ? reports!.count : tasks!.count
	}
	
	func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        if listType == ListType.report {
            let theData = reports![row]
            // Calculate height to fit content
            if tempCell == nil {
                tempCell = tableView.make(withIdentifier: String(describing: ReportCell.self), owner: self) as? ReportCell
            }
            ReportCellPresenter(cell: tempCell!).present(theReport: theData)
            
            return tempCell!.heightThatFits
        }
        else {
            let theData = tasks![row]
            // Return predefined height
            switch Int(theData.taskType.int32Value) {
                case TaskType.issue.rawValue, TaskType.gitCommit.rawValue:
                    return kTaskCellHeight
                default:
                    return kNonTaskCellHeight
            }
        }
	}
}

extension TasksScrollView: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView,
                    viewFor tableColumn: NSTableColumn?,
                    row: Int) -> NSView? {
        
        if listType == ListType.report {
            let theData = reports![row]
            let cell: CellProtocol = cellForTaskType(NSNumber(value: 0))
            ReportCellPresenter(cell: cell).present(theReport: theData)
            
            return cell as? NSView
        }
        else {
            var theData = tasks![row]
            let thePreviousData: Task? = (row + 1 < tasks!.count) ? tasks![row+1] : nil
            var cell: CellProtocol = cellForTaskType(theData.taskType)
            TaskCellPresenter(cell: cell).present(previousTask: thePreviousData, currentTask: theData)
            
            cell.didEndEditingCell = { [weak self] (cell: CellProtocol) in
                let updatedData = cell.data
                theData.taskNumber = updatedData.taskNumber
                theData.notes = updatedData.notes
                theData.endDate = updatedData.dateEnd
                self?.tasks![row] = theData// save the changes locally because the struct is passed by copying
                let saveInteractor = TaskInteractor(data: localRepository)
                saveInteractor.saveTask(theData)
            }
            cell.didRemoveCell = { [weak self] (cell: CellProtocol) in
                // Ugly hack to find the row number from which the action came
                tableView.enumerateAvailableRowViews({ (rowView, rowIndex) -> Void in
                    if rowView.subviews.first! == cell as! NSTableRowView {
                        self?.didRemoveRow?(rowIndex)
                        return
                    }
                })
            }
            cell.didAddCell = { [weak self] (cell: CellProtocol) in
                // Ugly hack to find the row number from which the action came
                tableView.enumerateAvailableRowViews( { rowView, rowIndex in
                    if rowView.subviews.first! == cell as! NSTableRowView {
                        self?.didAddRow?(rowIndex)
                        return
                    }
                })
            }
            
            return cell as? NSView
        }
    }
}

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
	
	@IBOutlet private var tableView: NSTableView?
    private var tempCell: ReportCell?
	
    var listType: ListType = ListType.AllTasks
	var data = [Task]()
	var didSelectRow: ((row: Int) -> ())?
	var didAddRow: ((row: Int) -> ())?
	var didRemoveRow: ((row: Int) -> ())?
	
	
	override func awakeFromNib() {
        super.awakeFromNib()
		
		tableView?.setDataSource(self)
		tableView?.setDelegate(self)
		
		assert(NSNib(nibNamed: String(TaskCell), bundle: NSBundle.mainBundle()) != nil, "err")
        assert(NSNib(nibNamed: String(NonTaskCell), bundle: NSBundle.mainBundle()) != nil, "err")
        assert(NSNib(nibNamed: String(ReportCell), bundle: NSBundle.mainBundle()) != nil, "err")
		
		if let nib = NSNib(nibNamed: String(TaskCell), bundle: NSBundle.mainBundle()) {
			tableView?.registerNib(nib, forIdentifier: String(TaskCell))
		}
		if let nib = NSNib(nibNamed: String(NonTaskCell), bundle: NSBundle.mainBundle()) {
			tableView?.registerNib(nib, forIdentifier: String(NonTaskCell))
        }
        if let nib = NSNib(nibNamed: String(ReportCell), bundle: NSBundle.mainBundle()) {
            tableView?.registerNib(nib, forIdentifier: String(ReportCell))
        }
	}
	
	func reloadData() {
		self.tableView?.reloadData()
	}
	
	func addTask (task: Task) {
		data.insert(task, atIndex: 0)
	}
	
    func removeTaskAtRow (row: Int) {
		data.removeAtIndex(row)
        self.tableView?.removeRowsAtIndexes(NSIndexSet(index: row), withAnimation: NSTableViewAnimationOptions.EffectFade)
	}
    
    func cellForTaskType (taskType: NSNumber) -> CellProtocol {
        
        var cell: CellProtocol? = nil
        if listType == ListType.Report {
            cell = self.tableView?.makeViewWithIdentifier(String(ReportCell), owner: self) as? ReportCell
        } else {
            switch Int(taskType.intValue) {
            case TaskType.Issue.rawValue, TaskType.GitCommit.rawValue:
                cell = self.tableView?.makeViewWithIdentifier(String(TaskCell), owner: self) as? TaskCell
                break
            default:
                cell = self.tableView?.makeViewWithIdentifier(String(NonTaskCell), owner: self) as? NonTaskCell
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
	
	func numberOfRowsInTableView (aTableView: NSTableView) -> Int {
		return data.count
	}
	
	func tableView (tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        let theData = data[row]
        if listType == ListType.Report {
            if tempCell == nil {
                tempCell = tableView.makeViewWithIdentifier(String(ReportCell), owner: self) as? ReportCell
            }
            TaskCellPresenter(cell: tempCell!).presentData(theData, andPreviousData: nil)
            return tempCell!.heightThatFits
        } else {
            switch Int(theData.taskType.intValue) {
                case TaskType.Issue.rawValue, TaskType.GitCommit.rawValue:
                    return kTaskCellHeight
                default:
                    return kNonTaskCellHeight
            }
        }
	}
}

extension TasksScrollView: NSTableViewDelegate {
    
    func tableView (tableView: NSTableView,
                    viewForTableColumn tableColumn: NSTableColumn?,
                    row: Int) -> NSView? {
        
        var theData = data[row]
        let thePreviousData: Task? = (row + 1 < data.count) ? data[row+1] : nil
        var cell: CellProtocol = cellForTaskType(theData.taskType)
        TaskCellPresenter(cell: cell).presentData(theData, andPreviousData: thePreviousData)
        
        cell.didEndEditingCell = { [weak self] (cell: CellProtocol) in
            let updatedData = cell.data
            theData.taskNumber = updatedData.taskNumber
            theData.notes = updatedData.notes
            theData.endDate = updatedData.dateEnd
            self?.data[row] = theData// save the changes locally because the struct is passed by copying
            let saveInteractor = TaskInteractor(data: localRepository)
            saveInteractor.saveTask(theData)
        }
        cell.didRemoveCell = { [weak self] (cell: CellProtocol) in
            // Ugly hack to find the row number from which the action came
            tableView.enumerateAvailableRowViewsUsingBlock({ (rowView, rowIndex) -> Void in
                if rowView.subviews.first! == cell as! NSTableRowView {
                    self?.didRemoveRow?(row: rowIndex)
                    return
                }
            })
        }
        cell.didAddCell = { [weak self] (cell: CellProtocol) in
            // Ugly hack to find the row number from which the action came
            tableView.enumerateAvailableRowViewsUsingBlock( { rowView, rowIndex in
                if rowView.subviews.first! == cell as! NSTableRowView {
                    self?.didAddRow?(row: rowIndex)
                    return
                }
            })
        }
        
        return cell as? NSView
    }
}

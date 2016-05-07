//
//  TasksScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

let kNonTaskCellHeight = CGFloat(40.0)
let kTaskCellMinHeight = CGFloat(70.0)
let kTaskCellMaxHeight = CGFloat(90.0)

class TasksScrollView: NSScrollView {
	
	@IBOutlet var tableView: NSTableView?
	
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
		assert(NSNib(nibNamed: String(GitCell), bundle: NSBundle.mainBundle()) != nil, "err")
		
		if let nib = NSNib(nibNamed: String(TaskCell), bundle: NSBundle.mainBundle()) {
			tableView?.registerNib(nib, forIdentifier: String(TaskCell))
		}
		if let nib = NSNib(nibNamed: String(NonTaskCell), bundle: NSBundle.mainBundle()) {
			tableView?.registerNib(nib, forIdentifier: String(NonTaskCell))
		}
		if let nib = NSNib(nibNamed: String(GitCell), bundle: NSBundle.mainBundle()) {
			tableView?.registerNib(nib, forIdentifier: String(GitCell))
		}
	}
	
	func reloadData() {
		self.tableView?.reloadData()
	}
	
	func addTask (task: Task) {
		data.insert(task, atIndex: 0)
	}
	
    func removeTaskAtRow (row: Int) {
        let theData = data[row];
		localRepository.deleteTask(theData)
		data.removeAtIndex(row)
        self.tableView?.removeRowsAtIndexes(NSIndexSet(index: row), withAnimation: NSTableViewAnimationOptions.EffectFade)
	}
}

extension TasksScrollView: NSTableViewDataSource {
	
	func numberOfRowsInTableView (aTableView: NSTableView) -> Int {
		return data.count
	}
	
	func tableView (tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		
		let theData = data[row]
		switch Int(theData.taskType!.intValue) {
			case TaskType.Issue.rawValue:
				return kTaskCellMaxHeight
			case TaskType.GitCommit.rawValue:
				return kTaskCellMinHeight
			default:
				return kNonTaskCellHeight
		}
	}
}

extension TasksScrollView: NSTableViewDelegate {
    
    func tableView (tableView: NSTableView,
                    viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var theData = data[row]
        let thePreviousData: Task? = (row + 1 < data.count) ? data[row+1] : nil
        var cell: TaskCellProtocol? = nil
        switch Int(theData.taskType!.intValue) {
        case TaskType.Issue.rawValue:
            cell = self.tableView?.makeViewWithIdentifier(String(TaskCell), owner: self) as? TaskCell
            break
        case TaskType.GitCommit.rawValue:
            cell = self.tableView?.makeViewWithIdentifier(String(GitCell), owner: self) as? GitCell
            break
        default:
            cell = self.tableView?.makeViewWithIdentifier(String(NonTaskCell), owner: self) as? NonTaskCell
            break
        }
        assert(cell != nil, "Cell can't be nil, check if the identifier is registered")
        
        // Add data to the cell
        TaskCellPresenter(cell: cell!).presentData(theData, andPreviousData: thePreviousData)
        
        cell?.didEndEditingCell = { [weak self] (cell: TaskCellProtocol) in
            theData.issueType = cell.data.issueType
            theData.notes = cell.data.notes
            if cell.data.dateEnd != "" {
                let hm = NSDate.parseHHmm(cell.data.dateEnd)
                theData.endDate = theData.endDate!.dateByUpdatingHour(hm.hour, minute: hm.min)
            }
            self?.data[row] = theData// save the changes locally because the struct is passed by copying
            // Save to server
            localRepository.saveTask(theData, completion: { (success) -> Void in
                RCLog(success)
            })
        }
        cell?.didRemoveCell = { [weak self] (cell: TaskCellProtocol) in
            // Ugly hack to find the row number from which the action came
            tableView.enumerateAvailableRowViewsUsingBlock({ (rowView, rowIndex) -> Void in
                if rowView.subviews.first! == cell as! NSTableRowView {
                    self?.didRemoveRow?(row: rowIndex)
                    return
                }
            })
        }
        cell?.didAddCell = { [weak self] (cell: TaskCellProtocol) in
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

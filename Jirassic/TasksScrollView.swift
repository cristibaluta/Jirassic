//
//  TasksScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

let kTaskCellNibName = "TaskCell"
let kNonTaskCellNibName = "NonTaskCell"
let kTaskCellIdentifier = "TaskCellIdentifier"
let kNonTaskCellIdentifier = "NonTaskCellIdentifier"
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
		
		tableView?.setDataSource(self)
		tableView?.setDelegate(self)
		
		assert(NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) != nil, "err")
		assert(NSNib(nibNamed: kNonTaskCellNibName, bundle: NSBundle.mainBundle()) != nil, "err")
		
		if let nib = NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) {
			tableView?.registerNib(nib, forIdentifier: kTaskCellIdentifier)
		}
		if let nib = NSNib(nibNamed: kNonTaskCellNibName, bundle: NSBundle.mainBundle()) {
			tableView?.registerNib(nib, forIdentifier: kNonTaskCellIdentifier)
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
		sharedData.deleteTask(theData)
		data.removeAtIndex(row)
        self.tableView?.removeRowsAtIndexes(NSIndexSet(index: row), withAnimation: NSTableViewAnimationOptions.EffectFade)
	}
}

extension TasksScrollView: NSTableViewDataSource, NSTableViewDelegate {
	
	func numberOfRowsInTableView (aTableView: NSTableView) -> Int {
		return data.count
	}
	
	func tableView (tableView: NSTableView,
		viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
			
		var theData = data[row]
		var cell: TaskCellProtocol? = nil
		switch Int(theData.taskType!.intValue) {
			case TaskType.Issue.rawValue:
				cell = self.tableView?.makeViewWithIdentifier(kTaskCellIdentifier, owner: self) as? TaskCell
			default:
				cell = self.tableView?.makeViewWithIdentifier(kNonTaskCellIdentifier, owner: self) as? NonTaskCell
		}
		assert(cell != nil, "Cell can't be nil, check the identifier")
		
		// Add data to the cell
		TaskCellPresenter(cell: cell!).presentData(theData, andPreviousData: row < data.count-1 ? data[row+1] : nil)
		
		cell?.didEndEditingCell = { (cell: TaskCellProtocol) in
			theData.issueType = cell.data.issue
			theData.notes = cell.data.notes
			self.data[row] = theData// save the changes locally because the struct is passed by copying
			// Save to server
			sharedData.updateTask(theData, completion: { (success) -> Void in
				RCLog(success)
			})
		}
		cell?.didRemoveCell = { (cell: TaskCellProtocol) in
			tableView.enumerateAvailableRowViewsUsingBlock({ (rowView, rowIndex) -> Void in
				if rowView.subviews.first! == cell as! NSTableRowView {
					self.didRemoveRow?(row: rowIndex)
					return
				}
			})
		}
		cell?.didAddCell = { (cell: TaskCellProtocol) in
			tableView.enumerateAvailableRowViewsUsingBlock({ rowView, rowIndex in
				if rowView.subviews.first! == cell as! NSTableRowView {
					self.didAddRow?(row: rowIndex)
					return
				}
			})
		}
		
		return cell as? NSView
	}
	
	func tableView (tableView: NSTableView, setObjectValue object: AnyObject?,
		forTableColumn tableColumn: NSTableColumn?, row: Int) {

			RCLog("set object value for row \(row)")
//			data?[row].setObject(object!, forKey: (tableColumn?.identifier)!)
	}
	
	func tableView (tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		let theData = data[row]
		return Int(theData.taskType!.intValue) == TaskType.Issue.rawValue ? kTaskCellMaxHeight : kNonTaskCellHeight
	}
}

//
//  TaskCellDataSource.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import Foundation

let kTaskCellNibName = "TaskCell"
let kNonTaskCellNibName = "NonTaskCell"
let kTaskCellIdentifier = "TaskCellIdentifier"
let kNonTaskCellIdentifier = "NonTaskCellIdentifier"
let kNonTaskCellHeight = CGFloat(40.0)
let kTaskCellMinHeight = CGFloat(70.0)
let kTaskCellMaxHeight = CGFloat(90.0)

class TasksDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	
	var tableView: NSTableView? {
		didSet {
			assert(NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) != nil, "err")
			assert(NSNib(nibNamed: kNonTaskCellNibName, bundle: NSBundle.mainBundle()) != nil, "err")
			
			if let nib = NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) {
				tableView?.registerNib( nib, forIdentifier: kTaskCellIdentifier)
			}
			if let nib = NSNib(nibNamed: kNonTaskCellNibName, bundle: NSBundle.mainBundle()) {
				tableView?.registerNib( nib, forIdentifier: kNonTaskCellIdentifier)
			}
		}
	}
	var data: [Task]?
	var didSelectRow: ((row: Int) -> ())?
	var didRemoveRow: ((row: Int) -> ())?
	
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
		RCLogO(aTableView)
		if let d = data {
			return d.count
		}
		return 0
	}
	
	func tableView(tableView: NSTableView,
		viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
			
			let theData = data![row] as Task
			var cell: TaskCellProtocol? = nil
			if theData.task_type?.intValue == 0 {
				cell = self.tableView?.makeViewWithIdentifier(kTaskCellIdentifier, owner: self) as? TaskCell
			} else {
				cell = self.tableView?.makeViewWithIdentifier(kNonTaskCellIdentifier, owner: self) as? NonTaskCell
			}
			assert(cell != nil, "Cell can't be nil, check the identifier")
			cell?.data = (date: theData.date_task_finished!.HHmm(), task: theData.task_nr!, notes: theData.notes!)
			cell?.didEndEditingCell = { (cell: TaskCellProtocol) in
				RCLogO(cell)
				let data = cell.data
				theData.task_nr = data.1
				theData.notes = data.2
				JLTaskWriter().write( theData )
			}
			cell?.didRemoveCell = { (cell: TaskCellProtocol) in
				RCLogO("remove cell \(self.didRemoveRow)")
				if self.didRemoveRow != nil {
					self.didRemoveRow!(row: tableView.rowForView(cell as! TaskCell))
				}
			}
			
			if theData.task_type?.intValue == 0 {
				return cell as? TaskCell
			} else {
				return cell as? NonTaskCell
			}
	}
	
	func tableView(tableView: NSTableView, setObjectValue object: AnyObject?,
		forTableColumn tableColumn: NSTableColumn?, row: Int) {

			RCLog("set object value for row \(row)")
//			data?[row].setObject(object!, forKey: (tableColumn?.identifier)!)
	}
	
//	func tableViewSelectionDidChange(aNotification: NSNotification) {
//		RCLogO(aNotification)
//		if let tableView: AnyObject = aNotification.object {
//			RCLogO(tableView.selectedRow)
//			if didSelectRow != nil {
//				didSelectRow!(row: tableView.selectedRow)
//			}
//		}
//	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		let theData = data![row] as Task
		return theData.task_type?.intValue == 0 ? kTaskCellMaxHeight : kNonTaskCellHeight
	}
	
	
	// MARK: Add and remove objects
	
	func addTask(task: Task) {
//		data?.append( task )
		data?.insert(task, atIndex: 0)
	}
	
	func removeTask(task: Task) {
//		data?.removeAtIndex( 0 )
	}
}

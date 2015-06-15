//
//  TaskCellDataSource.swift
//  Jirassic
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

class TasksScrollView: NSScrollView, NSTableViewDataSource, NSTableViewDelegate {
	
	@IBOutlet private var tableView: NSTableView?
	var data: [Task]?
	var didSelectRow: ((row: Int) -> ())?
	var didRemoveRow: ((row: Int) -> ())?
	
	
	override func awakeFromNib() {
		
		assert(NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) != nil, "err")
		assert(NSNib(nibNamed: kNonTaskCellNibName, bundle: NSBundle.mainBundle()) != nil, "err")
		
		if let nib = NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) {
			tableView?.registerNib( nib, forIdentifier: kTaskCellIdentifier)
		}
		if let nib = NSNib(nibNamed: kNonTaskCellNibName, bundle: NSBundle.mainBundle()) {
			tableView?.registerNib( nib, forIdentifier: kNonTaskCellIdentifier)
		}
	}
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
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
			
		var date = ""
		var notes = theData.notes!
		if theData.date_task_finished == nil && theData.date_task_started != nil {
			date = theData.date_task_started!.HHmm()
			cell?.statusImage!.image = NSImage(named: NSImageNameStatusPartiallyAvailable)
		} else {
			if row < data!.count-1 {
				let thePreviosData = data![row+1] as Task
				
				if Int(theData.task_type!.intValue) == TaskType.Issue.rawValue {
					if let dateEnd = theData.date_task_finished {
						let duration = dateEnd.timeIntervalSinceDate(thePreviosData.date_task_finished!)
						date = "\(dateEnd.HHmm())\n\(NSDate(timeIntervalSince1970: duration).HHmmGMT())h"
						cell?.statusImage!.image = NSImage(named: NSImageNameStatusAvailable)
					}
					else {
						date = "\(theData.date_task_finished!.HHmm())\n..."
						cell?.statusImage!.image = NSImage(named: NSImageNameStatusPartiallyAvailable)
					}
				}
				else {
					date = "\(thePreviosData.date_task_finished!.HHmm()) - \(theData.date_task_finished!.HHmm())"
					cell?.statusImage!.image = nil
				}
			} else {
				// This is always the Start cell
				notes = "\(notes) at \(theData.date_task_finished!.HHmm())"
				cell?.statusImage!.image = nil
			}
		}
		cell?.data = (dateStart: date, dateEnd: date, task: theData.task_nr!, notes: notes)
		cell?.didEndEditingCell = { (cell: TaskCellProtocol) in
			theData.task_nr = cell.data.task
			theData.notes = cell.data.notes
			JLTaskWriter().write( theData )
		}
		cell?.didRemoveCell = { (cell: TaskCellProtocol) in
			if self.didRemoveRow != nil {
				let row2 = tableView.rowForView(cell as! TaskCell)
				RCLogO("remove row \(row2)")
				self.didRemoveRow!(row: row)
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
		data?.insert(task, atIndex: 0)
	}
	
	func removeTask(task: Task) {
//		data?.removeAtIndex( 0 )
	}
}

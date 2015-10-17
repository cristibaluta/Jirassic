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
	
	var data = [TaskProtocol]()
	var didSelectRow: ((row: Int) -> ())?
	var didAddRow: ((row: Int) -> ())?
	var didRemoveRow: ((row: Int) -> ())?
	
	
	override func awakeFromNib() {
		
		tableView?.setDataSource( self )
		tableView?.setDelegate( self )
		
		assert(NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) != nil, "err")
		assert(NSNib(nibNamed: kNonTaskCellNibName, bundle: NSBundle.mainBundle()) != nil, "err")
		
		if let nib = NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) {
			tableView?.registerNib( nib, forIdentifier: kTaskCellIdentifier)
		}
		if let nib = NSNib(nibNamed: kNonTaskCellNibName, bundle: NSBundle.mainBundle()) {
			tableView?.registerNib( nib, forIdentifier: kNonTaskCellIdentifier)
		}
	}
	
	func reloadData() {
		self.tableView?.reloadData()
	}
	
	func addTask(task: TaskProtocol) {
		data.insert(task, atIndex: 0)
	}
	
	func removeTask(task: TaskProtocol) {
		//		data?.removeAtIndex( 0 )
	}
}

extension TasksScrollView: NSTableViewDataSource, NSTableViewDelegate {
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
		return data.count
	}
	
	func tableView(tableView: NSTableView,
		viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
			
		let theData = data[row]
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
			if row < data.count-1 {
				let thePreviosData = data[row+1]
				
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
		cell?.data = (dateStart: date, dateEnd: date, issue: theData.issue_type ?? "", notes: notes)
		cell?.didEndEditingCell = { (cell: TaskCellProtocol) in
			theData.issue_type = cell.data.issue
			theData.notes = cell.data.notes
			theData.saveToParseWhenPossible()
		}
		cell?.didRemoveCell = { (cell: TaskCellProtocol) in
			if self.didRemoveRow != nil {
				let row2 = tableView.rowForView(cell as! TaskCell)
				RCLogO("remove row \(row2)")
				self.didRemoveRow!(row: row)
			}
		}
		cell?.didAddCell = { (cell: TaskCellProtocol) in
			if self.didAddRow != nil {
				if let cell = cell as? TaskCell {
					let row2 = tableView.rowForView(cell)
					RCLogO("add row \(row2)")
					self.didAddRow!(row: row)
				} else if let cell = cell as? NonTaskCell {
					let row2 = tableView.rowForView(cell)
					RCLogO("add row \(row2)")
					self.didAddRow!(row: row)
				}
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
		let theData = data[row]
		return theData.task_type?.intValue == 0 ? kTaskCellMaxHeight : kNonTaskCellHeight
	}
}

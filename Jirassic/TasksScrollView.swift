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
	
	func addTask(task: Task) {
		data.insert(task, atIndex: 0)
	}
	
    func removeTaskAtRow(row: Int) {
        let theData = data[row];
//        theData.deleteFromServerWhenPossible()
		data.removeAtIndex(row)
        self.tableView?.removeRowsAtIndexes(NSIndexSet(index: row), withAnimation: NSTableViewAnimationOptions.EffectFade)
	}
}

extension TasksScrollView: NSTableViewDataSource, NSTableViewDelegate {
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
		return data.count
	}
	
	func tableView(tableView: NSTableView,
		viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
			
		var theData = data[row]
		var cell: TaskCellProtocol? = nil
		if theData.taskType?.intValue == 0 {
			cell = self.tableView?.makeViewWithIdentifier(kTaskCellIdentifier, owner: self) as? TaskCell
		} else {
			cell = self.tableView?.makeViewWithIdentifier(kNonTaskCellIdentifier, owner: self) as? NonTaskCell
		}
		assert(cell != nil, "Cell can't be nil, check the identifier")
			
		var date = ""
		var notes = theData.notes!
		if theData.endDate == nil && theData.startDate != nil {
			date = theData.startDate!.HHmm()
			cell?.statusImage!.image = NSImage(named: NSImageNameStatusPartiallyAvailable)
		} else {
			if row < data.count-1 {
				let thePreviosData = data[row+1]
				
				if Int(theData.taskType!.intValue) == TaskType.Issue.rawValue {
					if let dateEnd = theData.endDate {
						let duration = dateEnd.timeIntervalSinceDate(thePreviosData.endDate!)
						date = "\(dateEnd.HHmm())\n\(NSDate(timeIntervalSince1970: duration).HHmmGMT())h"
						cell?.statusImage!.image = NSImage(named: NSImageNameStatusAvailable)
					}
					else {
						date = "\(theData.endDate!.HHmm())\n..."
						cell?.statusImage!.image = NSImage(named: NSImageNameStatusPartiallyAvailable)
					}
				}
				else {
					date = "\(thePreviosData.endDate!.HHmm()) - \(theData.endDate!.HHmm())"
					cell?.statusImage!.image = nil
				}
			} else {
				// This is always the Start cell
				notes = "\(notes) at \(theData.endDate!.HHmm())"
				cell?.statusImage!.image = nil
			}
		}
		cell?.data = (dateStart: date, dateEnd: date, issue: theData.issueType ?? "", notes: notes)
		cell?.didEndEditingCell = { (cell: TaskCellProtocol) in
			theData.issueType = cell.data.issue
			theData.notes = cell.data.notes
//			theData.saveToServerWhenPossible()
		}
		cell?.didRemoveCell = { (cell: TaskCellProtocol) in
			if self.didRemoveRow != nil {
                if let cell = cell as? TaskCell {
                    let row2 = tableView.rowForView(cell)
                    RCLogO("remove row \(row2)")
                    self.didRemoveRow!(row: row)
                }
				else if let cell = cell as? NonTaskCell {
                    let row2 = tableView.rowForView(cell)
                    RCLogO("remove row \(row2)")
                    self.didRemoveRow!(row: row)
                }
			}
		}
		cell?.didAddCell = { (cell: TaskCellProtocol) in
			if self.didAddRow != nil {
				if let cell = cell as? TaskCell {
					let row2 = tableView.rowForView(cell)
					RCLogO("add row \(row2)")
					self.didAddRow!(row: row)
				}
				else if let cell = cell as? NonTaskCell {
					let row2 = tableView.rowForView(cell)
					RCLogO("add row \(row2)")
					self.didAddRow!(row: row)
				}
			}
		}
		
		if theData.taskType?.intValue == 0 {
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
		return theData.taskType?.intValue == 0 ? kTaskCellMaxHeight : kNonTaskCellHeight
	}
}

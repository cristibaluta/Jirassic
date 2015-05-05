//
//  NotesCellDataSource.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

let kTaskCellNibName = "TaskCell"
let kTaskCellIdentifier = "TaskCellIdentifier"
let kTaskCellMinHeight = CGFloat(70.0)
let kTaskCellMaxHeight = CGFloat(90.0)

class TaskCellDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {
	
	var tableView: NSTableView? {
		didSet {
			if let nib = NSNib(nibNamed: kTaskCellNibName, bundle: NSBundle.mainBundle()) {
				tableView?.registerNib( nib, forIdentifier: kTaskCellIdentifier)
			}
		}
	}
	var data: [Task]?
	var didSelectRow: ((row: Int) -> ())?
	var didRemoveRow: ((row: Int) -> ())?
	
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
		
		if let d = data {
			return d.count
		}
		return 0
	}
	
	func tableView(tableView: NSTableView,
		viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
			
			let theData = data![row] as Task
			let view = self.tableView?.makeViewWithIdentifier(kTaskCellIdentifier, owner: self) as! TaskCell
			view.issueNrTextField?.stringValue = theData.task_nr!
			view.notesTextField?.stringValue = theData.notes!
			view.dateEndTextField?.stringValue = theData.date_task_finished!.HHmm()
			view.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.SourceList
			view.didEndEditingCell = { (cell: TaskCell) in
				RCLogO(cell)
				theData.task_nr = cell.issueNrTextField?.stringValue
				theData.notes = cell.notesTextField?.stringValue
				JLTaskWriter().write( theData )
			}
			view.didRemoveCell = { (cell: TaskCell) in
				RCLogO("remove cell \(self.didRemoveRow)")
				if self.didRemoveRow != nil {
					self.didRemoveRow!(row: tableView.rowForView(cell))
				}
			}
			
			return view
	}
	
	func tableView(tableView: NSTableView, setObjectValue object: AnyObject?,
		forTableColumn tableColumn: NSTableColumn?, row: Int) {

			RCLog("set object value for row \(row)")
//			data?[row].setObject(object!, forKey: (tableColumn?.identifier)!)
	}
	
	func tableViewSelectionDidChange(aNotification: NSNotification) {
		RCLogO(aNotification)
		if let tableView: AnyObject = aNotification.object {
			RCLogO(tableView.selectedRow)
			if didSelectRow != nil {
				didSelectRow!(row: tableView.selectedRow)
			}
		}
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		return kTaskCellMaxHeight
	}
	
	
	// MARK: Add and remove objects
	
	func addTask(task: Task) {
		data?.append( task )
	}
	
	func removeTask(task: Task) {
		data?.removeAtIndex( 0 )
	}
}

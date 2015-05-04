//
//  DateCellDataSource.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class DateCellDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {

	let rowHeight = CGFloat(20)
	let columnDateId = "date"
	let columnProgressId = "progress"
	
	var tableView: NSTableView?
	var data: [Task]?
	var didSelectRow: ((row: Int) -> ())?
	
	override init() {
		
	}
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
		
		let numberOfRows: Int = data!.count
		return numberOfRows
	}
	
	func tableView(tableView: NSTableView,
		objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
			
			let object = data![row] as Task
			
			if (tableColumn?.identifier == columnDateId) {
				return object.date_task_finished?.MMdd()
			}
			else if (tableColumn?.identifier == columnProgressId) {
				return NSImage(named: NSImageNameStatusPartiallyAvailable)
			}
			return "..."
	}
	
	func tableViewSelectionDidChange(aNotification: NSNotification) {
		
		if let rowView: AnyObject = aNotification.object {
			if didSelectRow != nil {
				didSelectRow!(row: rowView.selectedRow)
			}
		}
	}
	
	func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
		return rowHeight
	}
}

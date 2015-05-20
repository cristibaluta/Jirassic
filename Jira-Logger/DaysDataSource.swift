//
//  DateCellDataSource.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class DaysDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {

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
			
		let theData = data![row]
		
		if (tableColumn?.identifier == columnDateId) {
			return theData.date_task_finished?.EEMMdd()
		}
		else if (tableColumn?.identifier == columnProgressId) {
			if let date = theData.date_task_finished {
				if date.isSameDayAs(NSDate()) {
					return NSImage(named: NSImageNameStatusPartiallyAvailable)
				}
			}
			return NSImage(named: NSImageNameStatusAvailable)
		}
		return nil
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

//
//  DateCellDataSource.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class DateCellDataSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {

	var tableView: NSTableView?
	var data: [JiraData]?
	var didSelectRow: ((row: Int) -> ())?
	
	override init() {
		
	}
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
		
		let numberOfRows: Int = data!.count
		RCLogI(numberOfRows)
		return numberOfRows
	}
	
	func tableView(tableView: NSTableView,
		objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
			
			let object = data![row] as JiraData
			
			if (tableColumn?.identifier == "date") {
				return object.date_task_finished?.MMdd()
			} else if (tableColumn?.identifier == "progress") {
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
		return 30.0
	}
}

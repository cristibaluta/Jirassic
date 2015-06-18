//
//  DaysScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class DaysScrollView: NSScrollView, NSTableViewDataSource, NSTableViewDelegate {
	
	@IBOutlet private var tableView: NSTableView?
	
	let rowHeight = CGFloat(20)
	let columnDateId = "date"
	let columnProgressId = "progress"
	
	var data = [TaskProtocol]()
	var didSelectRow: ((row: Int) -> ())?
	
	
	override func awakeFromNib() {
		tableView?.setDataSource( self )
		tableView?.setDelegate( self )
	}
	
	func reloadData() {
		self.tableView?.reloadData()
	}
	
	func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
		
		let numberOfRows: Int = data.count
		return numberOfRows
	}
	
	func tableView(tableView: NSTableView,
		objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
			
		let theData = data[row]
		
		if (tableColumn?.identifier == columnDateId) {
			return theData.date_task_finished?.ddEEEEE()
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

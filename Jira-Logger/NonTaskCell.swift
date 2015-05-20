//
//  ScrumCell.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 07/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NonTaskCell: NSTableRowView, TaskCellProtocol, NSTextFieldDelegate {
	
	@IBOutlet var statusImage: NSImageView?
	@IBOutlet private var dateEndTextField: NSTextField?
	@IBOutlet private var notesTextField: NSTextField?
	
	var didEndEditingCell: ((cell: TaskCellProtocol) -> ())?
	var didRemoveCell: ((cell: TaskCellProtocol) -> ())?
	var data: (date: String, task: String, notes: String) {
		get {
			return (self.dateEndTextField!.stringValue,
				"",
				self.notesTextField!.stringValue)
		}
		set {
			self.dateEndTextField!.stringValue = newValue.date
			self.notesTextField!.stringValue = newValue.notes
		}
	}
}

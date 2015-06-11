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
	var didAddCell: ((cell: TaskCellProtocol) -> ())?
	var didCopyContentCell: ((cell: TaskCellProtocol) -> ())?
	var data: (dateStart: String, dateEnd: String, task: String, notes: String) {
		get {
			return ("",
					self.dateEndTextField!.stringValue,
					"",
					self.notesTextField!.stringValue)
		}
		set {
//			self.dateEndTextField!.stringValue = newValue.date
			self.notesTextField!.stringValue = "\(newValue.notes) \(newValue.dateEnd)"
		}
	}
	
	override func drawBackgroundInRect(dirtyRect: NSRect) {
		
		let selectionRect = NSRect(x: 0, y: 6, width: dirtyRect.size.width-10, height: dirtyRect.size.height-12)
		NSColor(calibratedWhite: 0.80, alpha: 1.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
		selectionPath.fill()
		
		let lineRect = NSRect(x: 10, y: 0, width: 1, height: dirtyRect.size.height)
		NSColor(calibratedWhite: 0.80, alpha: 1.0).setFill()
		let linePath = NSBezierPath(rect: lineRect)
		linePath.fill()
	}
}

//
//  NotesCell.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCell: NSTableRowView, NSTextFieldDelegate {

	@IBOutlet var issueNrTextField: NSTextField?
	@IBOutlet var dateEndTextField: NSTextField?
	@IBOutlet var notesTextField: NSTextField?
	@IBOutlet var butRemove: NSButton?
	
	var didEndEditingCell: ((cell: TaskCell) -> ())?
	var didRemoveCell: ((cell: TaskCell) -> ())?
	private var isEditing = false
	private var wasEdited = false
	
	override func controlTextDidBeginEditing(obj: NSNotification) {
		RCLogO(obj.name)
		isEditing = true
	}
	
	override func controlTextDidChange(obj: NSNotification){
		RCLogO(obj.name)
		wasEdited = true
	}
	
	override func controlTextDidEndEditing(obj: NSNotification) {
		RCLogO(obj.name)
		if wasEdited {
			self.didEndEditingCell!(cell: self)
			wasEdited = false
		}
	}
	
	@IBAction func handleRemoveButton(sender: NSButton) {
		RCLogO("rremve cell");
		self.didRemoveCell!(cell: self)
	}
	
//	override func drawSelectionInRect(dirtyRect: NSRect) {
////		if (self.selectionHighlightStyle != NSTableViewSelectionHighlightStyle.None) {
//			self.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
//			let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
//			NSColor(calibratedWhite: 0.65, alpha: 1.0).setStroke()
//			NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()
//			let selectionPath = NSBezierPath(roundedRect: selectionRect,
//				xRadius: 6, yRadius: 6)
//			selectionPath.fill()
//			selectionPath.stroke()
////		}
//	}
}

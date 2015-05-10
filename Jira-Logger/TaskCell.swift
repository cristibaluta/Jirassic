//
//  NotesCell.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCell: NSTableRowView, TaskCellProtocol, NSTextFieldDelegate {

	@IBOutlet private var dateEndTextField: NSTextField?
	@IBOutlet private var issueNrTextField: NSTextField?
	@IBOutlet private var notesTextField: NSTextField?
	@IBOutlet private var butRemove: NSButton?
	
	private var isEditing = false
	private var wasEdited = false
	
	var didEndEditingCell: ((cell: TaskCellProtocol) -> ())?
	var didRemoveCell: ((cell: TaskCellProtocol) -> ())?
	var data: (date: String, task: String, notes: String) {
		get {
			return (self.dateEndTextField!.stringValue,
					self.issueNrTextField!.stringValue,
					self.notesTextField!.stringValue)
		}
		set {
			self.dateEndTextField!.stringValue = newValue.date
			self.issueNrTextField!.stringValue = newValue.task
			self.notesTextField!.stringValue = newValue.notes
		}
	}
	
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

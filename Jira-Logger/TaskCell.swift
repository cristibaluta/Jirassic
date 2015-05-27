//
//  NotesCell.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCell: NSTableRowView, TaskCellProtocol, NSTextFieldDelegate {
	
	@IBOutlet var statusImage: NSImageView?
	@IBOutlet private var dateEndTextField: NSTextField?
	@IBOutlet private var issueNrTextField: NSTextField?
	@IBOutlet private var notesTextField: NSTextField?
	@IBOutlet private var butRemove: NSButton?
	
	private var isEditing = false
	private var wasEdited = false
	private var mouseInside = false;
	private var trackingArea: NSTrackingArea?;
	
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
	
	override func awakeFromNib() {
		self.butRemove?.hidden = true
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
	
	override func drawBackgroundInRect(dirtyRect: NSRect) {
		
		if (self.mouseInside) {
			let selectionRect = NSRect(x: 65, y: 2, width: dirtyRect.size.width-74, height: dirtyRect.size.height-2)
			NSColor(calibratedWhite: 0.65, alpha: 1.0).setStroke()
			NSColor(calibratedWhite: 0.82, alpha: 0.3).setFill()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
			selectionPath.fill()
			selectionPath.stroke()
		}
		else {
			let selectionRect = NSRect(x: 60, y: 0, width: dirtyRect.size.width-70, height: dirtyRect.size.height)
			NSColor(calibratedWhite: 0.65, alpha: 0.0).setStroke()
			NSColor(calibratedWhite: 0.82, alpha: 0.0).setFill()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
			selectionPath.fill()
			selectionPath.stroke()
		}
	}
	
	override func drawSelectionInRect(dirtyRect: NSRect) {
//		self.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
		let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
		NSColor(calibratedWhite: 0.65, alpha: 1.0).setStroke()
		NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
		selectionPath.fill()
		selectionPath.stroke()
	}
	
	// MARK: mouse
	
	override func mouseEntered(theEvent: NSEvent) {
		self.mouseInside = true
		self.butRemove?.hidden = false
		self.setNeedsDisplayInRect(self.frame)
	}
	
	override func mouseExited(theEvent: NSEvent) {
		self.mouseInside = false
		self.butRemove?.hidden = true
		self.setNeedsDisplayInRect(self.frame)
	}
	
	func ensureTrackingArea() {
		if (trackingArea == nil) {
			trackingArea = NSTrackingArea(rect: NSZeroRect,
				options: NSTrackingAreaOptions.InVisibleRect |
						NSTrackingAreaOptions.ActiveAlways |
						NSTrackingAreaOptions.MouseEnteredAndExited,
				owner: self,
				userInfo: nil)
		}
	}
	
	override func updateTrackingAreas() {
		super.updateTrackingAreas()
		self.ensureTrackingArea()
		if (!(self.trackingAreas as NSArray).containsObject(self.trackingArea!)) {
			self.addTrackingArea(self.trackingArea!);
		}
	}

}

//
//  NotesCell.swift
//  Jirassic
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
	@IBOutlet private var butAdd: NSButton?
	@IBOutlet private var butCopy: NSButton?
	@IBOutlet private var datePicker: NSDatePicker?
	
	private var isEditing = false
	private var wasEdited = false
	private var mouseInside = false
	private var trackingArea: NSTrackingArea?
	
	var didEndEditingCell: ((cell: TaskCellProtocol) -> ())?
	var didRemoveCell: ((cell: TaskCellProtocol) -> ())?
	var didAddCell: ((cell: TaskCellProtocol) -> ())?
	var didCopyContentCell: ((cell: TaskCellProtocol) -> ())?
	var data: (dateStart: String, dateEnd: String, task: String, notes: String) {
		get {
			return (self.dateEndTextField!.stringValue,
					self.dateEndTextField!.stringValue,
					self.issueNrTextField!.stringValue,
					self.notesTextField!.stringValue)
		}
		set {
			self.dateEndTextField!.stringValue = newValue.dateEnd
			self.issueNrTextField!.stringValue = newValue.task
			self.notesTextField!.stringValue = newValue.notes
		}
	}
	
	override func awakeFromNib() {
		self.showMouseOverControls(false)
		self.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
	}
	
	override func controlTextDidBeginEditing(obj: NSNotification) {
		isEditing = true
	}
	
	override func controlTextDidChange(obj: NSNotification){
		wasEdited = true
	}
	
	override func controlTextDidEndEditing(obj: NSNotification) {
		if wasEdited {
			self.didEndEditingCell!(cell: self)
			wasEdited = false
		}
	}
	
	// MARK: Acions
	
	@IBAction func handleRemoveButton(sender: NSButton) {
		self.didRemoveCell!(cell: self)
	}
	
	@IBAction func handleAddButton(sender: NSButton) {
		self.didAddCell!(cell: self)
	}
	
	@IBAction func handleCopyButton(sender: NSButton) {
		NSPasteboard.generalPasteboard().clearContents()
		NSPasteboard.generalPasteboard().writeObjects([notesTextField!.stringValue])
	}
	
	override func drawBackgroundInRect(dirtyRect: NSRect) {
		
		if (self.mouseInside) {
			let selectionRect = NSRect(x: 65, y: 20, width: dirtyRect.size.width-74, height: dirtyRect.size.height-20)
			NSColor(calibratedWhite: 0.4, alpha: 1.0).setStroke()
			NSColor(calibratedWhite: 1.0, alpha: 1.0).setFill()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
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
		
		let lineRect = NSRect(x: 10, y: 0, width: 1, height: dirtyRect.size.height)
		NSColor(calibratedWhite: 0.80, alpha: 1.0).setFill()
		let linePath = NSBezierPath(rect: lineRect)
		linePath.fill()
	}
	
	override func drawSelectionInRect(dirtyRect: NSRect) {
		
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
		self.showMouseOverControls(self.mouseInside)
		self.setNeedsDisplayInRect(self.frame)
	}
	
	override func mouseExited(theEvent: NSEvent) {
		self.mouseInside = false
		self.showMouseOverControls(self.mouseInside)
		self.setNeedsDisplayInRect(self.frame)
	}
	
	func showMouseOverControls(show: Bool) {
		self.butRemove?.hidden = !show
		self.butAdd?.hidden = !show
		self.butCopy?.hidden = !show
		self.datePicker?.hidden = !show
	}
	
	func ensureTrackingArea() {
		if (trackingArea == nil) {
			trackingArea = NSTrackingArea(rect: NSZeroRect,
				options: [NSTrackingAreaOptions.InVisibleRect, NSTrackingAreaOptions.ActiveAlways, NSTrackingAreaOptions.MouseEnteredAndExited],
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

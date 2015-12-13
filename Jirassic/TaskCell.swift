//
//  TaskCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCell: NSTableRowView, TaskCellProtocol {
	
	@IBOutlet var statusImage: NSImageView?
	@IBOutlet private var dateEndTextField: NSTextField?
	@IBOutlet private var durationTextField: NSTextField?
	@IBOutlet private var issueNrTextField: NSTextField?
	@IBOutlet private var notesTextField: NSTextField?
	@IBOutlet private var butRemove: NSButton?
	@IBOutlet private var butAdd: NSButton?
	@IBOutlet private var butCopy: NSButton?
	
	private var isEditing = false
	private var wasEdited = false
	private var mouseInside = false
	private var trackingArea: NSTrackingArea?
	
	var didEndEditingCell: ((cell: TaskCellProtocol) -> ())?
	var didRemoveCell: ((cell: TaskCellProtocol) -> ())?
	var didAddCell: ((cell: TaskCellProtocol) -> ())?
	var didCopyContentCell: ((cell: TaskCellProtocol) -> ())?
	
	// Sets the data to the cell
	var data: TaskCreationData {
		get {
			return (self.dateEndTextField!.stringValue,
					self.dateEndTextField!.stringValue,
					self.issueNrTextField!.stringValue,
					self.notesTextField!.stringValue)
		}
		set {
			self.dateEndTextField!.stringValue = newValue.dateEnd
			self.issueNrTextField!.stringValue = newValue.issue
			self.notesTextField!.stringValue = newValue.notes
		}
	}
	var duration: String {
		get {
			return durationTextField!.stringValue
		}
		set {
			self.durationTextField!.stringValue = newValue
		}
	}
	
	// Sets the end date of the task to the UI picker. It can be edited and requested back
	var date: NSDate {
		get {
			return NSDate()// self.datePicker!.dateValue
		}
		set {
			//self.datePicker!.dateValue = newValue
		}
	}
	
	override func awakeFromNib() {
		showMouseOverControls(false)
		selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
	}
	
	
	// MARK: Acions
	
	@IBAction func handleRemoveButton (sender: NSButton) {
		didRemoveCell?(cell: self)
	}
	
	@IBAction func handleAddButton (sender: NSButton) {
		didAddCell?(cell: self)
	}
	
	@IBAction func handleCopyButton (sender: NSButton) {
		NSPasteboard.generalPasteboard().clearContents()
		NSPasteboard.generalPasteboard().writeObjects([notesTextField!.stringValue])
	}
	
	override func drawBackgroundInRect (dirtyRect: NSRect) {
		
		if (self.mouseInside) {
			let selectionRect = dirtyRect
			NSColor(calibratedWhite: 0.4, alpha: 1.0).setStroke()
			NSColor(calibratedWhite: 1.0, alpha: 1.0).setFill()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
			selectionPath.fill()
			
//			let selectionRect = NSRect(x: 65, y: 20, width: dirtyRect.size.width-74, height: dirtyRect.size.height-20)
//			NSColor(calibratedWhite: 0.4, alpha: 1.0).setStroke()
//			NSColor(calibratedWhite: 1.0, alpha: 1.0).setFill()
//			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 0, yRadius: 0)
//			selectionPath.fill()
//			selectionPath.stroke()
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
	
	override func drawSelectionInRect (dirtyRect: NSRect) {
		
		let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
		NSColor(calibratedWhite: 0.65, alpha: 1.0).setStroke()
		NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
		selectionPath.fill()
		selectionPath.stroke()
	}
	
	// MARK: mouse
	
	override func mouseEntered (theEvent: NSEvent) {
		self.mouseInside = true
		self.showMouseOverControls(self.mouseInside)
		self.setNeedsDisplayInRect(self.frame)
	}
	
	override func mouseExited (theEvent: NSEvent) {
		self.mouseInside = false
		self.showMouseOverControls(self.mouseInside)
		self.setNeedsDisplayInRect(self.frame)
	}
	
	func showMouseOverControls (show: Bool) {
		self.butRemove?.hidden = !show
		self.butAdd?.hidden = !show
		self.butCopy?.hidden = !show
		self.dateEndTextField?.editable = show
		self.durationTextField?.editable = show
	}
	
	func ensureTrackingArea() {
		if (trackingArea == nil) {
			trackingArea = NSTrackingArea(
				rect: NSZeroRect,
				options: [NSTrackingAreaOptions.InVisibleRect, .ActiveAlways, .MouseEnteredAndExited],
				owner: self,
				userInfo: nil
			)
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

extension TaskCell: NSTextFieldDelegate {
	
	override func controlTextDidBeginEditing (obj: NSNotification) {
		isEditing = true
	}
	
	override func controlTextDidChange (obj: NSNotification){
		wasEdited = true
		if obj.object as? NSTextField == dateEndTextField {
			RCLog(obj);
			RCLog(dateEndTextField?.stringValue)
		}
	}
	
	override func controlTextDidEndEditing (obj: NSNotification) {
		if wasEdited {
			self.didEndEditingCell?(cell: self)
			wasEdited = false
		}
	}
	
	func control (control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
		
		if textView == dateEndTextField {
			RCLog(commandSelector)
		}
		return true
	}
}

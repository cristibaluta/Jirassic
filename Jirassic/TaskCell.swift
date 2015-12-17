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
	
	// Sets data to the cell
	var _dateEnd = ""
	var data: TaskCreationData {
		get {
			return (dateStart: self.dateEndTextField!.stringValue,
					dateEnd: self.dateEndTextField!.stringValue,
					issue: self.issueNrTextField!.stringValue,
					notes: self.notesTextField!.stringValue)
		}
		set {
			self.dateEndTextField!.stringValue = newValue.dateEnd
			self.issueNrTextField!.stringValue = newValue.issue
			self.notesTextField!.stringValue = newValue.notes
			_dateEnd = newValue.dateEnd
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
			let selectionRect = NSRect(x: 10, y: 6, width: dirtyRect.size.width-20, height: dirtyRect.size.height-12)
			NSColor(calibratedWhite: 0.8, alpha: 1.0).setFill()
			NSColor(calibratedWhite: 0.3, alpha: 1.0).setStroke()
//			NSColor(calibratedRed: 0.3, green: 0.1, blue: 0.1, alpha: 1.0).setStroke()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
			selectionPath.fill()
			selectionPath.stroke()
		}
		else {
			let selectionRect = NSRect(x: 10, y: 6, width: dirtyRect.size.width-20, height: dirtyRect.size.height-12)
			NSColor(calibratedWhite: 0.80, alpha: 1.0).setFill()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
			selectionPath.fill()
		}
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
		if !(self.trackingAreas as NSArray).containsObject(self.trackingArea!) {
			self.addTrackingArea(self.trackingArea!);
		}
	}
}

extension TaskCell: NSTextFieldDelegate {
	
	override func controlTextDidBeginEditing (obj: NSNotification) {
		isEditing = true
	}
	
	override func controlTextDidChange (obj: NSNotification) {
		wasEdited = true
		if obj.object as? NSTextField == dateEndTextField {
			let predictor = PredictiveTimeTyping()
			let comps = dateEndTextField!.stringValue.componentsSeparatedByString(_dateEnd)
			let newDigit = (comps.count == 1 && _dateEnd != "") ? "" : comps.last
			_dateEnd = predictor.timeByAdding(newDigit!, to: _dateEnd)
			dateEndTextField?.stringValue = _dateEnd
		}
	}
	
	override func controlTextDidEndEditing (obj: NSNotification) {
		if wasEdited {
			self.didEndEditingCell?(cell: self)
			wasEdited = false
		}
	}
	
	func control (control: NSControl, textView: NSTextView, doCommandBySelector commandSelector: Selector) -> Bool {
		
		if control as? NSTextField == dateEndTextField {
			RCLog(commandSelector)
			if wasEdited && commandSelector == "insertNewline:" {
				self.didEndEditingCell?(cell: self)
				wasEdited = false
			}
		}
		return false
	}
}

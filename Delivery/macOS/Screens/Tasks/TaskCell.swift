//
//  TaskCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCell: NSTableRowView, CellProtocol {
	
	@IBOutlet var statusImage: NSImageView?
	@IBOutlet fileprivate var dateEndTextField: NSTextField?
	@IBOutlet fileprivate var durationTextField: NSTextField?
	@IBOutlet fileprivate var issueNrTextField: NSTextField?
	@IBOutlet fileprivate var notesTextField: NSTextField?
	@IBOutlet fileprivate var butRemove: NSButton?
	@IBOutlet fileprivate var butAdd: NSButton?
	@IBOutlet fileprivate var butCopy: NSButton?
	
	fileprivate var isEditing = false
	fileprivate var wasEdited = false
	fileprivate var mouseInside = false
	fileprivate var trackingArea: NSTrackingArea?
	
	var didEndEditingCell: ((_ cell: CellProtocol) -> ())?
	var didRemoveCell: ((_ cell: CellProtocol) -> ())?
	var didAddCell: ((_ cell: CellProtocol) -> ())?
	var didCopyContentCell: ((_ cell: CellProtocol) -> ())?
	
	// Sets data to the cell
	var _dateEnd = ""
	var data: TaskCreationData {
		get {
            let hm = Date.parseHHmm(self.dateEndTextField!.stringValue)
            let date = Date().dateByUpdating(hour: hm.hour, minute: hm.min)
			return (dateStart: nil,
			        dateEnd: date,
					taskNumber: self.issueNrTextField!.stringValue,
					notes: self.notesTextField!.stringValue)
		}
		set {
            _dateEnd = newValue.dateEnd.HHmm()
            self.dateEndTextField!.stringValue = _dateEnd
			self.issueNrTextField!.stringValue = newValue.taskNumber
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
	
	override func awakeFromNib() {
		showMouseOverControls(false)
		selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
	}
	
	
	// MARK: Actions
	
	@IBAction func handleRemoveButton (_ sender: NSButton) {
		didRemoveCell?(self)
	}
	
	@IBAction func handleAddButton (_ sender: NSButton) {
		didAddCell?(self)
	}
	
	@IBAction func handleCopyButton (_ sender: NSButton) {
		NSPasteboard.general().clearContents()
		NSPasteboard.general().writeObjects([notesTextField!.stringValue as NSPasteboardWriting])
	}
	
	override func drawBackground (in dirtyRect: NSRect) {
		
		if (self.mouseInside) {
			let selectionRect = NSRect(x: 10, y: 6, width: dirtyRect.size.width-20, height: dirtyRect.size.height-12)
			NSColor(calibratedWhite: 1.0, alpha: 1.0).setFill()
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
	
	override func drawSelection (in dirtyRect: NSRect) {
		
		let selectionRect = NSInsetRect(self.bounds, 2.5, 2.5)
		NSColor(calibratedWhite: 0.65, alpha: 1.0).setStroke()
		NSColor(calibratedWhite: 0.82, alpha: 1.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
		selectionPath.fill()
		selectionPath.stroke()
	}
	
	
	// MARK: mouse
	
	override func mouseEntered (with theEvent: NSEvent) {
		self.mouseInside = true
		self.showMouseOverControls(self.mouseInside)
		self.setNeedsDisplay(self.frame)
	}
	
	override func mouseExited (with theEvent: NSEvent) {
		self.mouseInside = false
		self.showMouseOverControls(self.mouseInside)
		self.setNeedsDisplay(self.frame)
	}
	
	func showMouseOverControls (_ show: Bool) {
		self.butRemove?.isHidden = !show
		self.butAdd?.isHidden = !show
		self.butCopy?.isHidden = !show
		self.dateEndTextField?.isEditable = show
		self.durationTextField?.isEditable = show
	}
	
	func ensureTrackingArea() {
		if (trackingArea == nil) {
			trackingArea = NSTrackingArea(
				rect: NSZeroRect,
				options: [NSTrackingAreaOptions.inVisibleRect, .activeAlways, .mouseEnteredAndExited],
				owner: self,
				userInfo: nil
			)
		}
	}
	
	override func updateTrackingAreas() {
		super.updateTrackingAreas()
		self.ensureTrackingArea()
		if !(self.trackingAreas as NSArray).contains(self.trackingArea!) {
			self.addTrackingArea(self.trackingArea!);
		}
	}
}

extension TaskCell: NSTextFieldDelegate {
	
	override func controlTextDidBeginEditing (_ obj: Notification) {
		isEditing = true
	}
	
	override func controlTextDidChange (_ obj: Notification) {
		wasEdited = true
		if obj.object as? NSTextField == dateEndTextField {
			let predictor = PredictiveTimeTyping()
			let comps = dateEndTextField!.stringValue.components(separatedBy: _dateEnd)
			let newDigit = (comps.count == 1 && _dateEnd != "") ? "" : comps.last
			_dateEnd = predictor.timeByAdding(newDigit!, to: _dateEnd)
			dateEndTextField?.stringValue = _dateEnd
		}
	}
	
	override func controlTextDidEndEditing (_ obj: Notification) {
		if wasEdited {
			self.didEndEditingCell?(self)
			wasEdited = false
		}
	}
	
	func control (_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
		
		if control as? NSTextField == dateEndTextField {
			RCLog(commandSelector)
			if wasEdited && commandSelector == #selector(NSResponder.insertNewline(_:)) {
				self.didEndEditingCell?(self)
				wasEdited = false
			}
		}
		return false
	}
}

//
//  ScrumCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 07/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NonTaskCell: NSTableRowView, CellProtocol {
	
	@IBOutlet var statusImage: NSImageView?
	@IBOutlet private var dateEndTextField: NSTextField?
	@IBOutlet private var notesTextField: NSTextField?
	@IBOutlet private var notesTextFieldTrailingContraint: NSLayoutConstraint?
	@IBOutlet private var butRemove: NSButton?
	@IBOutlet private var butAdd: NSButton?
	
	private var trackingArea: NSTrackingArea?
	
	var didEndEditingCell: ((cell: CellProtocol) -> ())?
	var didRemoveCell: ((cell: CellProtocol) -> ())?
	var didAddCell: ((cell: CellProtocol) -> ())?
	var didCopyContentCell: ((cell: CellProtocol) -> ())?
	var data: TaskCreationData {
		get {
			return (NSDate(),
					"",
					self.notesTextField!.stringValue)
		}
		set {
			self.dateEndTextField?.stringValue = newValue.dateEnd.HHmm()
			self.notesTextField?.stringValue = newValue.notes
		}
	}
	var duration: String {
		get {
			return ""//durationTextField!.stringValue
		}
		set {
//			self.durationTextField!.stringValue = newValue
		}
	}
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		self.butRemove?.hidden = true
		self.butAdd?.hidden = true
        self.butRemove?.wantsLayer = true
        self.butRemove?.layer?.backgroundColor = NSColor.clearColor().CGColor
		self.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
	}
	
	override func drawBackgroundInRect (dirtyRect: NSRect) {
		
		let selectionRect = NSRect(x: 10, y: 6, width: dirtyRect.size.width-20, height: dirtyRect.size.height-12)
		NSColor(calibratedWhite: 0.80, alpha: 1.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
		selectionPath.fill()
	}
	
	// MARK: Acions
	
	@IBAction func handleRemoveButton (sender: NSButton) {
		self.didRemoveCell?(cell: self)
	}
	
	@IBAction func handleAddButton (sender: NSButton) {
		self.didAddCell?(cell: self)
	}
	
	// MARK: mouse
	
	override func mouseEntered (theEvent: NSEvent) {
		self.butRemove?.hidden = false
		self.butAdd?.hidden = false
		self.notesTextFieldTrailingContraint?.constant = 80
		self.setNeedsDisplayInRect(self.frame)
	}
	
	override func mouseExited (theEvent: NSEvent) {
		self.butRemove?.hidden = true
		self.butAdd?.hidden = true
		self.notesTextFieldTrailingContraint?.constant = 10
		self.setNeedsDisplayInRect(self.frame)
	}
	
	func ensureTrackingArea() {
		if (trackingArea == nil) {
			trackingArea = NSTrackingArea(rect: NSZeroRect,
				options: [
                    NSTrackingAreaOptions.InVisibleRect,
                    NSTrackingAreaOptions.ActiveAlways,
                    NSTrackingAreaOptions.MouseEnteredAndExited
                ],
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

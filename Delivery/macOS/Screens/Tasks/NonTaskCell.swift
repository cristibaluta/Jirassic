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
	@IBOutlet fileprivate var dateEndTextField: NSTextField?
	@IBOutlet fileprivate var notesTextField: NSTextField?
	@IBOutlet fileprivate var notesTextFieldTrailingContraint: NSLayoutConstraint?
	@IBOutlet fileprivate var butRemove: NSButton?
	@IBOutlet fileprivate var butAdd: NSButton?
	
	fileprivate var trackingArea: NSTrackingArea?
	
	var didEndEditingCell: ((_ cell: CellProtocol) -> ())?
	var didRemoveCell: ((_ cell: CellProtocol) -> ())?
	var didAddCell: ((_ cell: CellProtocol) -> ())?
	var didCopyContentCell: ((_ cell: CellProtocol) -> ())?
	var data: TaskCreationData {
		get {
			return (Date(),
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
        
		self.butRemove?.isHidden = true
		self.butAdd?.isHidden = true
        self.butRemove?.wantsLayer = true
        self.butRemove?.layer?.backgroundColor = NSColor.clear.cgColor
		self.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.none
	}
	
	override func drawBackground (in dirtyRect: NSRect) {
		
		let selectionRect = NSRect(x: 10, y: 6, width: dirtyRect.size.width-20, height: dirtyRect.size.height-12)
		NSColor(calibratedWhite: 0.80, alpha: 1.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
		selectionPath.fill()
	}
	
	// MARK: Acions
	
	@IBAction func handleRemoveButton (_ sender: NSButton) {
		self.didRemoveCell?(self)
	}
	
	@IBAction func handleAddButton (_ sender: NSButton) {
		self.didAddCell?(self)
	}
	
	// MARK: mouse
	
	override func mouseEntered (with theEvent: NSEvent) {
		self.butRemove?.isHidden = false
		self.butAdd?.isHidden = false
		self.notesTextFieldTrailingContraint?.constant = 80
		self.setNeedsDisplay(self.frame)
	}
	
	override func mouseExited (with theEvent: NSEvent) {
		self.butRemove?.isHidden = true
		self.butAdd?.isHidden = true
		self.notesTextFieldTrailingContraint?.constant = 10
		self.setNeedsDisplay(self.frame)
	}
	
	func ensureTrackingArea() {
		if (trackingArea == nil) {
			trackingArea = NSTrackingArea(rect: NSZeroRect,
				options: [
                    NSTrackingAreaOptions.inVisibleRect,
                    NSTrackingAreaOptions.activeAlways,
                    NSTrackingAreaOptions.mouseEnteredAndExited
                ],
				owner: self,
				userInfo: nil)
		}
	}
	
	override func updateTrackingAreas() {
		super.updateTrackingAreas()
        
		self.ensureTrackingArea()
		if (!(self.trackingAreas as NSArray).contains(self.trackingArea!)) {
			self.addTrackingArea(self.trackingArea!);
		}
	}
}

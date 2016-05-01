//
//  GitCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 12/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class GitCell: NSTableRowView, TaskCellProtocol {

	@IBOutlet var statusImage: NSImageView?
	@IBOutlet private var dateEndTextField: NSTextField?
	@IBOutlet private var notesTextField: NSTextField?
	@IBOutlet private var butRemove: NSButton?
	@IBOutlet private var butAdd: NSButton?
	
	private var isEditing = false
    private var wasEdited = false
    private var mouseInside = false
	private var trackingArea: NSTrackingArea?
	
	var didEndEditingCell: ((cell: TaskCellProtocol) -> ())?
	var didRemoveCell: ((cell: TaskCellProtocol) -> ())?
	var didAddCell: ((cell: TaskCellProtocol) -> ())?
	var didCopyContentCell: ((cell: TaskCellProtocol) -> ())?
	var data: (dateStart: String, dateEnd: String, issueType: String, issueId: String, notes: String) {
		get {
			return ("",
				self.dateEndTextField!.stringValue,
				"",
				"",
				self.notesTextField!.stringValue)
		}
		set {
			//			self.dateEndTextField!.stringValue = newValue.date
			self.notesTextField!.stringValue = "\(newValue.notes) \(newValue.dateEnd)"
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
		self.butRemove?.hidden = true
		self.butAdd?.hidden = true
		self.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
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
	
	// MARK: Acions
	
	@IBAction func handleRemoveButton (sender: NSButton) {
		self.didRemoveCell?(cell: self)
	}
	
	@IBAction func handleAddButton (sender: NSButton) {
		self.didAddCell?(cell: self)
	}
	
	// MARK: mouse
	
//	override func mouseEntered (theEvent: NSEvent) {
//		self.butRemove?.hidden = false
//		self.butAdd?.hidden = false
//		self.setNeedsDisplayInRect(self.frame)
//	}
//	
//	override func mouseExited (theEvent: NSEvent) {
//		self.butRemove?.hidden = true
//		self.butAdd?.hidden = true
//		self.setNeedsDisplayInRect(self.frame)
//	}
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
//        self.butCopy?.hidden = !show
        self.dateEndTextField?.editable = show
//        self.durationTextField?.editable = show
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

extension GitCell: NSTextFieldDelegate {
	
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
		RCLog(commandSelector)
		return true
	}
}
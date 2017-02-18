//
//  TaskCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCell: NSTableRowView, CellProtocol {
    
    @IBOutlet var contentView: NSView?
    
	@IBOutlet var statusImage: NSImageView?
	@IBOutlet fileprivate var dateEndTextField: NSTextField?
	@IBOutlet fileprivate var issueNrTextField: NSTextField?
    @IBOutlet fileprivate var notesTextField: NSTextField?
    @IBOutlet fileprivate var notesTextFieldRightConstrain: NSLayoutConstraint?
    
    @IBOutlet fileprivate var butCopy: NSButton?
    @IBOutlet fileprivate var butAdd: NSButton?
	@IBOutlet fileprivate var butRemove: NSButton?
    
    @IBOutlet fileprivate var line1: NSBox?
    @IBOutlet fileprivate var line2: NSBox?
    @IBOutlet fileprivate var line3: NSBox?
	
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
			return (
                dateStart: nil,
                dateEnd: date,
                taskNumber: self.issueNrTextField!.stringValue,
                notes: self.notesTextField!.stringValue,
                taskType: .issue
            )
		}
		set {
            _dateEnd = newValue.dateEnd.HHmm()
            dateEndTextField!.stringValue = _dateEnd
			issueNrTextField!.stringValue = newValue.taskNumber
			notesTextField!.stringValue = newValue.notes
		}
	}
    var duration: String {
        get {
            return ""
        }
        set {
            
        }
    }
    
	override func awakeFromNib() {
        super.awakeFromNib()
		showMouseOverControls(false)
        notesTextFieldRightConstrain!.constant = 0
	}
}

extension TaskCell {
	
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
}

extension TaskCell {

	override func drawBackground (in dirtyRect: NSRect) {
		
        let width = dirtyRect.size.width - kCellLeftPadding * 2
        let height = dirtyRect.size.height - kGapBetweenCells - 1
        
		if self.mouseInside {
            notesTextFieldRightConstrain!.constant = 140
			let selectionRect = NSRect(x: kCellLeftPadding, y: 1, width: width, height: height)
			//NSColor(calibratedWhite: 1.0, alpha: 0.0).setFill()
			NSColor(calibratedWhite: 0.0, alpha: 0.4).setStroke()
//			NSColor(calibratedRed: 0.3, green: 0.1, blue: 0.1, alpha: 1.0).setStroke()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
//			selectionPath.fill()
			selectionPath.stroke()
		} else {
            notesTextFieldRightConstrain!.constant = 0
			let selectionRect = NSRect(x: kCellLeftPadding, y: 1, width: width, height: height)
			NSColor(calibratedWhite: 1.0, alpha: 1.0).setFill()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
			selectionPath.fill()
		}
	}
	
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
        line1?.isHidden = !show
        line2?.isHidden = !show
        line3?.isHidden = !show
		self.dateEndTextField?.isEditable = show
	}
	
	func ensureTrackingArea() {
		if trackingArea == nil {
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
            wasEdited = false
			self.didEndEditingCell?(self)
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

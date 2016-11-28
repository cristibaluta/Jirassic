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
    
    fileprivate var isEditing = false
    fileprivate var wasEdited = false
    fileprivate var trackingArea: NSTrackingArea?
    var _dateEnd = ""
	
	var didEndEditingCell: ((_ cell: CellProtocol) -> ())?
	var didRemoveCell: ((_ cell: CellProtocol) -> ())?
	var didAddCell: ((_ cell: CellProtocol) -> ())?
	var didCopyContentCell: ((_ cell: CellProtocol) -> ())?
	var data: TaskCreationData {
		get {
            let hm = Date.parseHHmm(self.dateEndTextField!.stringValue)
            let date = Date().dateByUpdating(hour: hm.hour, minute: hm.min)
			return (dateStart: nil,
			        dateEnd: date,
			        taskNumber: "",
			        notes: self.notesTextField!.stringValue)
		}
        set {
            _dateEnd = newValue.dateEnd.HHmm()
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
	}
	
	override func drawBackground (in dirtyRect: NSRect) {
        
		NSColor(calibratedWhite: 1.0, alpha: 0.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: dirtyRect, xRadius: 0, yRadius: 0)
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
        self.dateEndTextField?.isEditable = true
		self.notesTextFieldTrailingContraint?.constant = 80
		self.setNeedsDisplay(self.frame)
	}
	
	override func mouseExited (with theEvent: NSEvent) {
		self.butRemove?.isHidden = true
        self.butAdd?.isHidden = true
        self.dateEndTextField?.isEditable = false
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
		if !(self.trackingAreas as NSArray).contains(self.trackingArea!) {
			self.addTrackingArea(self.trackingArea!)
		}
	}
}

extension NonTaskCell: NSTextFieldDelegate {
    
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

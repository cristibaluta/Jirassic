//
//  NonTaskCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 07/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class NonTaskCell: NSTableRowView, CellProtocol {
	
    var statusImage: NSImageView?
    @IBOutlet fileprivate var dateStartTextField: NSTextField!
    @IBOutlet fileprivate var dateStartTextFieldWidthContraint: NSLayoutConstraint!
	@IBOutlet fileprivate var dateEndTextField: NSTextField!
	@IBOutlet fileprivate var notesTextField: NSTextField!
	@IBOutlet fileprivate var notesTextFieldTrailingContraint: NSLayoutConstraint!
	@IBOutlet fileprivate var butRemove: NSButton!
	@IBOutlet fileprivate var butAdd: NSButton!
    
    fileprivate var isEditing = false
    fileprivate var wasEdited = false
    fileprivate var trackingArea: NSTrackingArea?
    fileprivate var currentlyEditingTime = ""
	
	var didEndEditingCell: ((_ cell: CellProtocol) -> ())?
	var didRemoveCell: ((_ cell: CellProtocol) -> ())?
	var didAddCell: ((_ cell: CellProtocol) -> ())?
	var didCopyContentCell: ((_ cell: CellProtocol) -> ())?
    
    fileprivate var _data: TaskCreationData?
	var data: TaskCreationData {
		get {
            if let dateStart = _data?.dateStart {
                let newHM = Date.parseHHmm(self.dateStartTextField.stringValue)
                let date = dateStart.dateByUpdating(hour: newHM.hour, minute: newHM.min)
                _data?.dateStart = date
            }
            let newHM = Date.parseHHmm(self.dateEndTextField.stringValue)
            let dateEnd = _data!.dateEnd.dateByUpdating(hour: newHM.hour, minute: newHM.min)
            _data?.dateEnd = dateEnd
            
            _data?.notes = self.notesTextField.stringValue
            
            return _data!
		}
        set {
            _data = newValue
            if let dateStart = newValue.dateStart {
                self.dateStartTextField.stringValue = dateStart.HHmm()
                self.dateStartTextFieldWidthContraint.constant = 40
            } else {
                self.dateStartTextField.stringValue = ""
                self.dateStartTextFieldWidthContraint.constant = 0
            }
            self.dateEndTextField.stringValue = newValue.dateEnd.HHmm()
			self.notesTextField.stringValue = newValue.notes
		}
	}
	var duration: String {
		get {
			return ""
		}
        set {
            
        }
    }
    var isDark: Bool = false
    var isEditable: Bool = true
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		butRemove.isHidden = true
		butAdd.isHidden = true
        butRemove.wantsLayer = true
        dateStartTextField!.textColor = AppDelegate.sharedApp().theme.textColor
        dateEndTextField!.textColor = AppDelegate.sharedApp().theme.textColor
        if AppDelegate.sharedApp().theme.isDark {
            notesTextField!.textColor = NSColor.white
        }
//        self.butRemove.layer?.backgroundColor = NSColor.clear.cgColor
	}
	
	override func drawBackground (in dirtyRect: NSRect) {
        
		NSColor(calibratedWhite: 1.0, alpha: 0.0).setFill()
		let selectionPath = NSBezierPath(roundedRect: dirtyRect, xRadius: 0, yRadius: 0)
		selectionPath.fill()
	}
}

extension NonTaskCell {
	
	@IBAction func handleRemoveButton (_ sender: NSButton) {
		self.didRemoveCell?(self)
	}
	
	@IBAction func handleAddButton (_ sender: NSButton) {
		self.didAddCell?(self)
	}
}

extension NonTaskCell {
    
	override func mouseEntered (with theEvent: NSEvent) {
        
		self.butRemove.isHidden = false
        self.butAdd.isHidden = false
        self.dateStartTextField.isEditable = true
        self.dateEndTextField.isEditable = true
		self.notesTextFieldTrailingContraint.constant = 80
		self.setNeedsDisplay(self.frame)
	}
	
//    override func mouseMoved(with event: NSEvent) {
//        
//        let locationInWindow = event.locationInWindow
//        let locationInView = self.convert(locationInWindow, from: nil)
//        RCLog(locationInView)
//        if dateStartTextField.frame.contains(locationInView) {
//            dateStartTextField.font = NSFont.systemFont(ofSize: 14)
//        }
//    }
    
	override func mouseExited (with theEvent: NSEvent) {
        
		self.butRemove.isHidden = true
        self.butAdd.isHidden = true
        self.dateStartTextField.isEditable = false
        self.dateEndTextField.isEditable = false
		self.notesTextFieldTrailingContraint.constant = 10
		self.setNeedsDisplay(self.frame)
	}
	
	func ensureTrackingArea() {
        
		if (trackingArea == nil) {
			trackingArea = NSTrackingArea(rect: NSZeroRect,
				options: [
                    NSTrackingArea.Options.inVisibleRect,
                    NSTrackingArea.Options.activeAlways,
                    NSTrackingArea.Options.mouseEnteredAndExited
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
        if obj.object as? NSTextField == dateEndTextField {
            currentlyEditingTime = self.dateEndTextField.stringValue
        }
        else if obj.object as? NSTextField == dateStartTextField {
            currentlyEditingTime = self.dateStartTextField.stringValue
        }
    }
    
    override func controlTextDidChange (_ obj: Notification) {
        wasEdited = true
        if obj.object as? NSTextField == dateEndTextField {
            let predictor = PredictiveTimeTyping()
            let comps = dateEndTextField.stringValue.components(separatedBy: currentlyEditingTime)
            let newDigit = (comps.count == 1 && currentlyEditingTime != "") ? "" : comps.last
            currentlyEditingTime = predictor.timeByAdding(newDigit!, to: currentlyEditingTime)
            dateEndTextField.stringValue = currentlyEditingTime
        }
        else if obj.object as? NSTextField == dateStartTextField {
            let predictor = PredictiveTimeTyping()
            let comps = dateStartTextField.stringValue.components(separatedBy: currentlyEditingTime)
            let newDigit = (comps.count == 1 && currentlyEditingTime != "") ? "" : comps.last
            currentlyEditingTime = predictor.timeByAdding(newDigit!, to: currentlyEditingTime)
            dateStartTextField.stringValue = currentlyEditingTime
        }
    }
    
    override func controlTextDidEndEditing (_ obj: Notification) {
        if wasEdited {
            wasEdited = false
            self.didEndEditingCell?(self)
        }
    }
    
    func control (_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        // Detect enter key
        if control as? NSTextField == dateStartTextField {
            if wasEdited && commandSelector == #selector(NSResponder.insertNewline(_:)) {
                self.didEndEditingCell?(self)
                wasEdited = false
            }
        } else if control as? NSTextField == dateEndTextField {
            if wasEdited && commandSelector == #selector(NSResponder.insertNewline(_:)) {
                self.didEndEditingCell?(self)
                wasEdited = false
            }
        }
        return false
    }
}

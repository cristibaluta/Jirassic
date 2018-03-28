//
//  TaskCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCell: NSTableRowView, CellProtocol {
    
    @IBOutlet var contentView: NSView!
    
	@IBOutlet var statusImage: NSImageView?
	@IBOutlet fileprivate var dateEndTextField: TimeBox!
	@IBOutlet fileprivate var issueNrTextField: NSTextField!
    @IBOutlet fileprivate var notesTextField: NSTextField!
    @IBOutlet fileprivate var notesTextFieldRightConstrain: NSLayoutConstraint!
    
    @IBOutlet fileprivate var butAdd: NSButton!
	@IBOutlet fileprivate var butRemove: NSButton!
    
    @IBOutlet fileprivate var line1: NSBox!
    @IBOutlet fileprivate var line2: NSBox!
	
	fileprivate var isEditing = false
	fileprivate var wasEdited = false
	fileprivate var mouseInside = false
	fileprivate var trackingArea: NSTrackingArea?
	
	var didEndEditingCell: ((_ cell: CellProtocol) -> ())?
	var didRemoveCell: ((_ cell: CellProtocol) -> ())?
	var didAddCell: ((_ cell: CellProtocol) -> ())?
	var didCopyContentCell: ((_ cell: CellProtocol) -> ())?
	
	// Sets data to the cell
    var _dateEnd = Date()
	var _dateEndHHmm = ""
	var data: TaskCreationData {
		get {
            let hm = Date.parseHHmm(self.dateEndTextField!.stringValue)
            let date = _dateEnd.dateByUpdating(hour: hm.hour, minute: hm.min)
			return (
                dateStart: nil,
                dateEnd: date,
                taskNumber: self.issueNrTextField.stringValue,
                notes: self.notesTextField.stringValue,
                taskType: .issue
            )
		}
		set {
            _dateEnd = newValue.dateEnd
            _dateEndHHmm = _dateEnd.HHmm()
            dateEndTextField.stringValue = _dateEndHHmm
			issueNrTextField.stringValue = newValue.taskNumber
			notesTextField.stringValue = newValue.notes
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
    var isEditable: Bool = true {
        didSet {
            dateEndTextField.isEditable = isEditable
            issueNrTextField.isEditable = isEditable
            notesTextField.isEditable = isEditable
        }
    }
    
	override func awakeFromNib() {
        super.awakeFromNib()
		showMouseOverControls(false)
        notesTextFieldRightConstrain.constant = 0
        dateEndTextField.didEndEditing = {
            self.didEndEditingCell?(self)
        }
	}
}

extension TaskCell {
	
	@IBAction func handleRemoveButton (_ sender: NSButton) {
		didRemoveCell?(self)
	}
	
	@IBAction func handleAddButton (_ sender: NSButton) {
		didAddCell?(self)
	}
}

extension TaskCell {

	override func drawBackground (in dirtyRect: NSRect) {
		
        let width = dirtyRect.size.width - kCellLeftPadding * 2
        let height = dirtyRect.size.height - kGapBetweenCells - 2
        
		if self.mouseInside {
            notesTextFieldRightConstrain!.constant = 90
			let selectionRect = NSRect(x: kCellLeftPadding, y: 2, width: width, height: height)
			//NSColor(calibratedWhite: 1.0, alpha: 0.0).setFill()
            AppDelegate.sharedApp().theme.highlightLineColor.setStroke()
//			NSColor(calibratedRed: 0.3, green: 0.1, blue: 0.1, alpha: 1.0).setStroke()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
//			selectionPath.fill()
			selectionPath.stroke()
		} else {
            notesTextFieldRightConstrain!.constant = 0
			let selectionRect = NSRect(x: kCellLeftPadding, y: 2, width: width, height: height)
//            NSColor(calibratedWhite: 1.0, alpha: 1.0).setFill()
            AppDelegate.sharedApp().theme.lineColor.setStroke()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
//            selectionPath.fill()
            selectionPath.stroke()
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
		self.butRemove.isHidden = !show
		self.butAdd.isHidden = !show
        line1.isHidden = !show
        line2.isHidden = !show
		self.dateEndTextField?.isEditable = isEditable && show
	}
	
	func ensureTrackingArea() {
		if trackingArea == nil {
			trackingArea = NSTrackingArea(
				rect: NSZeroRect,
				options: [NSTrackingArea.Options.inVisibleRect,
                          NSTrackingArea.Options.activeAlways,
                          NSTrackingArea.Options.mouseEnteredAndExited],
				owner: self,
				userInfo: nil
			)
		}
	}
	
	override func updateTrackingAreas() {
		super.updateTrackingAreas()
		self.ensureTrackingArea()
		if !self.trackingAreas.contains(self.trackingArea!) {
			self.addTrackingArea(self.trackingArea!)
		}
	}
}

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
	@IBOutlet private var dateEndTextField: TimeBox!
	@IBOutlet private var issueNrTextField: NSTextField!
    @IBOutlet private var notesTextField: NSTextField!
    @IBOutlet private var notesTextFieldRightConstrain: NSLayoutConstraint!
    
    @IBOutlet private var butAdd: NSButton!
	@IBOutlet private var butRemove: NSButton!
    @IBOutlet private var butRemoveWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private var line1: NSBox!
    @IBOutlet private var line2: NSBox!
	
	private var isEditing = false
	private var wasEdited = false
	private var mouseInside = false
	private var trackingArea: NSTrackingArea?
    private var activeTimeboxPopover: NSPopover?
	
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
            fatalError("Not available")
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
    var isRemovable: Bool = true {
        didSet {
            butRemove.isEnabled = isRemovable
        }
    }
    var isIgnored: Bool = false
    var color: NSColor = NSColor.black {
        didSet {
            self.notesTextField!.textColor = color
        }
    }
    var timeToolTip: String? {
        didSet {
            self.toolTip = nil
            dateEndTextField.toolTip = timeToolTip
        }
    }
    
	override func awakeFromNib() {
        super.awakeFromNib()
		showMouseOverControls(false)
        notesTextFieldRightConstrain.constant = 0
        dateEndTextField.onClick = { [weak self] in
            if let wself = self {
                wself.createTimeboxPopover(timebox: wself.dateEndTextField)
            }
        }
	}
    
    private func createTimeboxPopover (timebox: TimeBox) {
        guard activeTimeboxPopover == nil else {
            return
        }
        let popover = NSPopover()
        let view = TimeBoxViewController.instantiateFromStoryboard("Components")
        view.didSave = {
            let hasChanges = timebox.stringValue != view.stringValue
            timebox.stringValue = view.stringValue
            popover.performClose(nil)
            if hasChanges {
                self.didEndEditingCell?(self)
            }
        }
        view.didCancel = {
            popover.performClose(nil)
            self.activeTimeboxPopover = nil
        }
        popover.contentViewController = view
        popover.show(relativeTo: timebox.frame, of: self, preferredEdge: NSRectEdge.maxY)
        view.stringValue = timebox.stringValue
        
        activeTimeboxPopover = popover
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
        
        if isEditing {
            let selectionRect = NSRect(x: kCellLeftPadding, y: 2, width: width, height: height)
            NSColor.red.setStroke()
            let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
            selectionPath.stroke()
        }
		else if self.mouseInside {
            notesTextFieldRightConstrain!.constant = isRemovable ? 90 : 40
            butRemoveWidthConstraint.constant = isRemovable ? 40 : 0
			let selectionRect = NSRect(x: kCellLeftPadding, y: 2, width: width, height: height)
			//NSColor(calibratedWhite: 1.0, alpha: 0.0).setFill()
            AppDelegate.sharedApp().theme.highlightLineColor.setStroke()
//			NSColor(calibratedRed: 0.3, green: 0.1, blue: 0.1, alpha: 1.0).setStroke()
			let selectionPath = NSBezierPath(roundedRect: selectionRect, xRadius: 6, yRadius: 6)
//			selectionPath.fill()
			selectionPath.stroke()
		}
        else {
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
        super.mouseEntered(with: theEvent)
		self.mouseInside = true
		self.showMouseOverControls(self.mouseInside)
		self.setNeedsDisplay(self.frame)
	}
	
    override func mouseExited (with theEvent: NSEvent) {
        super.mouseExited(with: theEvent)
		self.mouseInside = false
		self.showMouseOverControls(self.mouseInside)
		self.setNeedsDisplay(self.frame)
	}
	
	func showMouseOverControls (_ show: Bool) {
		butRemove.isHidden = !show
		butAdd.isHidden = !show
        line1.isHidden = !show
        line2.isHidden = !show
		dateEndTextField?.isEditable = isEditable && show
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

extension TaskCell: NSTextFieldDelegate {
    
    public func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        isEditing = true
        self.setNeedsDisplay(self.frame)
        return true
    }
    
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if wasEdited {
            wasEdited = false
            isEditing = false
            didEndEditingCell?(self)
            self.setNeedsDisplay(self.frame)
        }
        return true
    }
    
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        // Detect Enter key
        if wasEdited && commandSelector == #selector(NSResponder.insertNewline(_:)) {
            wasEdited = false
            isEditing = false
            didEndEditingCell?(self)
            self.setNeedsDisplay(self.frame)
        }
        return false
    }
    
    override func controlTextDidChange (_ obj: Notification) {
        wasEdited = true
    }
}

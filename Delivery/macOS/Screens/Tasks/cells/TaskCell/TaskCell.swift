//
//  NonTaskCell.swift
//  Jirassic
//
//  Created by Baluta Cristian on 07/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCell: NSTableRowView, CellProtocol {

    @IBOutlet var statusImage: NSImageView?
    @IBOutlet private var dateStartTextField: TimeBox!
    @IBOutlet private var dateStartTextFieldLeadingContraint: NSLayoutConstraint!
    @IBOutlet private var bullet: NSTextField!
    @IBOutlet private var dateEndTextField: TimeBox!
    @IBOutlet private var notesTextField: NSTextField!
    @IBOutlet private var notesTextFieldTrailingContraint: NSLayoutConstraint!
    @IBOutlet private var notesTextFieldWidthContraint: NSLayoutConstraint!
    @IBOutlet private var butRemove: NSButton!
    @IBOutlet private var butAdd: NSButton!
    @IBOutlet private var butEdit: NSButton!
    
    private var isEditing = false
    private var wasEdited = false
    private var isMouseOver = false
    private var trackingArea: NSTrackingArea?
    private var activeTimeboxPopover: NSPopover?
	
	var didClickEditCell: ((_ cell: CellProtocol) -> ())?
	var didClickRemoveCell: ((_ cell: CellProtocol) -> ())?
	var didClickAddCell: ((_ cell: CellProtocol) -> ())?
	var didCopyContentCell: ((_ cell: CellProtocol) -> ())?
    
    private var _data: TaskCreationData?
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
            
            if self.notesTextField.stringValue != "" {
                _data?.notes = self.notesTextField.stringValue
            }
            
            return _data!
		}
        set {
            _data = newValue
            if let dateStart = newValue.dateStart {
                self.dateStartTextField.stringValue = dateStart.HHmm()
                self.dateStartTextField.isHidden = false
                self.bullet.isHidden = false
                self.dateStartTextFieldLeadingContraint.constant = 20
            } else {
                self.dateStartTextField.isHidden = true
                self.bullet.isHidden = true
                self.dateStartTextFieldLeadingContraint.constant = 20 - 36 - 8
            }
            self.dateEndTextField.stringValue = newValue.dateEnd.HHmm()
			self.notesTextField.stringValue = (newValue.taskNumber ?? "") + " - " + (newValue.notes ?? "")
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
    var isDark: Bool = false {
        didSet {
            dateStartTextField.isDark = isDark
            dateEndTextField.isDark = isDark
        }
    }
    var isEditable: Bool = true {
        didSet {
            notesTextField.isEditable = isEditable
        }
    }
    var isRemovable: Bool = true
    var isIgnored: Bool = false {
        didSet {
            self.notesTextField!.alphaValue = isIgnored ? 0.5 : 1.0
        }
    }
    var color: NSColor = NSColor.black {
        didSet {
            self.notesTextField!.textColor = color
        }
    }
    var timeToolTip: String? {
        didSet {
            dateStartTextField.toolTip = timeToolTip
            dateEndTextField.toolTip = timeToolTip
        }
    }
	
	override func awakeFromNib() {
        super.awakeFromNib()
        
		butRemove.isHidden = true
		butAdd.isHidden = true
        butEdit.isHidden = true
        butRemove.wantsLayer = true
        dateStartTextField.onClick = {
            self.createTimeboxPopover(timebox: self.dateStartTextField)
        }
        dateEndTextField.onClick = {
            self.createTimeboxPopover(timebox: self.dateEndTextField)
        }
        if AppDelegate.sharedApp().theme.isDark {
            notesTextField!.textColor = NSColor.white
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.notesTextFieldWidthContraint.constant = dirtyRect.width - notesTextField.frame.origin.x - (isMouseOver ? 100 : 10)
    }

    override func drawBackground (in dirtyRect: NSRect) {

        NSColor(calibratedWhite: 1.0, alpha: 0.0).setFill()
        let selectionPath = NSBezierPath(roundedRect: dirtyRect, xRadius: 0, yRadius: 0)
        selectionPath.fill()
    }
    
    private func createTimeboxPopover (timebox: TimeBox) {
        guard activeTimeboxPopover == nil, isEditable else {
            return
        }
        let popover = NSPopover()
        let view = TimeBoxViewController.instantiateFromStoryboard("Tasks")
        view.didSave = {
            let hasChanges = timebox.stringValue != view.stringValue
            timebox.stringValue = view.stringValue
            popover.performClose(nil)
            if hasChanges {
                self.didClickEditCell?(self)
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
		didClickRemoveCell?(self)
	}
	
	@IBAction func handleAddButton (_ sender: NSButton) {
		didClickAddCell?(self)
	}
    
    @IBAction func handleEditButton (_ sender: NSButton) {
        didClickEditCell?(self)
    }
}

/// Mouse tracking
extension TaskCell {
    
	override func mouseEntered (with theEvent: NSEvent) {
        super.mouseEntered(with: theEvent)
        
		self.butRemove.isHidden = false
        self.butAdd.isHidden = false
        self.butEdit.isHidden = false
        self.isMouseOver = true
		self.setNeedsDisplay(self.frame)
	}
	
	override func mouseExited (with theEvent: NSEvent) {
        super.mouseExited(with: theEvent)
        
		self.butRemove.isHidden = true
        self.butAdd.isHidden = true
        self.butEdit.isHidden = true
        self.isMouseOver = false
		self.setNeedsDisplay(self.frame)
	}
	
	func ensureTrackingArea() {
        
		if trackingArea == nil {
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
		if !self.trackingAreas.contains(self.trackingArea!) {
			self.addTrackingArea(self.trackingArea!)
		}
	}
}

extension TaskCell: NSTextFieldDelegate {
    
    public func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        isEditing = true
        return true
    }
    
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if wasEdited {
            wasEdited = false
            didClickEditCell?(self)
        }
        return true
    }
    
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        // Detect Enter key
        if wasEdited && commandSelector == #selector(NSResponder.insertNewline(_:)) {
            didClickEditCell?(self)
            wasEdited = false
        }
        return false
    }
    
    func controlTextDidChange (_ obj: Notification) {
        wasEdited = true
    }
}

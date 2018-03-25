//
//  ReportCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/09/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Cocoa

class ReportCell: NSTableRowView, CellProtocol {

    var statusImage: NSImageView?
    @IBOutlet fileprivate var durationTextField: NSTextField?
    @IBOutlet fileprivate var taskNrTextField: NSTextField?
    @IBOutlet fileprivate var notesTextField: NSTextField?
    @IBOutlet fileprivate var butCopy: NSButton?
    @IBOutlet fileprivate var butCopyWidthConstraint: NSLayoutConstraint?
    fileprivate var trackingArea: NSTrackingArea?
    fileprivate var bgColor: NSColor = NSColor.clear
    
    var didEndEditingCell: ((_ cell: CellProtocol) -> ())?
    var didRemoveCell: ((_ cell: CellProtocol) -> ())?
    var didAddCell: ((_ cell: CellProtocol) -> ())?
    var didCopyContentCell: ((_ cell: CellProtocol) -> ())?
    
    var data: TaskCreationData {
        get {
            return (
                dateStart: nil,
                dateEnd: Date(),
                taskNumber: self.taskNrTextField!.stringValue,
                notes: self.notesTextField!.stringValue,
                taskType: .issue
            )
        }
        set {
            self.taskNrTextField!.stringValue = newValue.taskNumber
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
    var heightThatFits: CGFloat {
        get {
            let titleTextField = self.taskNrTextField!.sizeThatFits(
                NSSize(width: self.frame.size.width - 60 - 70, height: 1000)
            )
            let notesTextField = self.notesTextField!.sizeThatFits(
                NSSize(width: self.frame.size.width - self.notesTextField!.frame.origin.x, height: 1000)
            )
            
            return 6 + titleTextField.height + 4 + notesTextField.height + 6
        }
    }
    var isDark: Bool = false
    var isEditable: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        butCopyWidthConstraint?.constant = 0
        taskNrTextField?.preferredMaxLayoutWidth = CGFloat(300)
        ensureTrackingArea()
    }
    
    override func draw (_ dirtyRect: NSRect) {
        bgColor.set()
        dirtyRect.fill()
    }
    
    @IBAction func handleCopyButton (_ sender: NSButton) {
        
        let string = "\(taskNrTextField!.stringValue)\n\(notesTextField!.stringValue)"
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([string as NSPasteboardWriting])
    }
    
}

extension ReportCell {
    
    override func mouseEntered (with theEvent: NSEvent) {
        butCopyWidthConstraint?.constant = 47
        bgColor = NSColor.white
        butCopy!.needsLayout = true
        self.needsDisplay = true
        if isDark == true {
            taskNrTextField?.textColor = NSColor.black
            notesTextField?.textColor = NSColor.darkGray
            durationTextField?.textColor = NSColor.darkGray
        }
    }
    
    override func mouseExited (with theEvent: NSEvent) {
        butCopyWidthConstraint?.constant = 0
        bgColor = NSColor.clear
        butCopy!.needsLayout = true
        self.needsDisplay = true
        if isDark == true {
            taskNrTextField?.textColor = NSColor.white
            notesTextField?.textColor = NSColor.lightGray
            durationTextField?.textColor = NSColor.lightGray
        }
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        self.ensureTrackingArea()
        if (!(self.trackingAreas as NSArray).contains(self.trackingArea!)) {
            self.addTrackingArea(self.trackingArea!);
        }
    }
    
    func ensureTrackingArea() {
        if (trackingArea == nil) {
            trackingArea = NSTrackingArea(
                rect: self.bounds,
                options: [NSTrackingArea.Options.inVisibleRect, NSTrackingArea.Options.activeAlways, NSTrackingArea.Options.mouseEnteredAndExited],
                owner: self,
                userInfo: nil
            )
        }
    }
}

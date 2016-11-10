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
            return (dateEnd: Date(),
                    taskNumber: self.taskNrTextField!.stringValue,
                    notes: self.notesTextField!.stringValue)
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
            let size = self.notesTextField!.sizeThatFits(
                NSSize(width: self.frame.size.width - self.notesTextField!.frame.origin.x, height: 1000)
            )
            
            return 30 + size.height + 10
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        butCopyWidthConstraint?.constant = 0
        ensureTrackingArea()
    }
    
    override func draw (_ dirtyRect: NSRect) {
        bgColor.set()
        NSRectFill(dirtyRect)
    }
    
    @IBAction func handleCopyButton (_ sender: NSButton) {
        
        let string = "\(taskNrTextField!.stringValue)\n\(notesTextField!.stringValue)"
        NSPasteboard.general().clearContents()
        NSPasteboard.general().writeObjects([string as NSPasteboardWriting])
    }
    
}

extension ReportCell {
    
    override func mouseEntered (with theEvent: NSEvent) {
        butCopyWidthConstraint?.constant = 47
        bgColor = NSColor.white
        butCopy!.needsLayout = true
        self.needsDisplay = true
    }
    
    override func mouseExited (with theEvent: NSEvent) {
        butCopyWidthConstraint?.constant = 0
        bgColor = NSColor.clear
        butCopy!.needsLayout = true
        self.needsDisplay = true
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
                options: [NSTrackingAreaOptions.inVisibleRect, .activeAlways, .mouseEnteredAndExited],
                owner: self,
                userInfo: nil
            )
        }
    }
}

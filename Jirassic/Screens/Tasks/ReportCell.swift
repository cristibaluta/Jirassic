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
    @IBOutlet private var durationTextField: NSTextField?
    @IBOutlet private var taskNrTextField: NSTextField?
    @IBOutlet private var notesTextField: NSTextField?
    @IBOutlet private var butCopy: NSButton?
    @IBOutlet private var butCopyWidthConstraint: NSLayoutConstraint?
    private var trackingArea: NSTrackingArea?
    private var bgColor: NSColor = NSColor.clearColor()
    
    var didEndEditingCell: ((cell: CellProtocol) -> ())?
    var didRemoveCell: ((cell: CellProtocol) -> ())?
    var didAddCell: ((cell: CellProtocol) -> ())?
    var didCopyContentCell: ((cell: CellProtocol) -> ())?
    
    var data: TaskCreationData {
        get {
            return (dateEnd: NSDate(),
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
//            self.notesTextField!.sizeToFit()
            let size = self.notesTextField!.sizeThatFits(NSSize(width: self.frame.size.width, height: 1000))
            
            return 30 + size.height + 10
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        butCopyWidthConstraint?.constant = 0
        ensureTrackingArea()
    }
    
    override func drawRect (dirtyRect: NSRect) {
        bgColor.set()
        NSRectFill(dirtyRect)
    }
    
    @IBAction func handleCopyButton (sender: NSButton) {
        
        let string = "\(taskNrTextField!.stringValue)\n\(notesTextField!.stringValue)"
        NSPasteboard.generalPasteboard().clearContents()
        NSPasteboard.generalPasteboard().writeObjects([string])
    }
    
}

extension ReportCell {
    
    override func mouseEntered (theEvent: NSEvent) {
        butCopyWidthConstraint?.constant = 47
        bgColor = NSColor.whiteColor()
        butCopy!.needsLayout = true
        self.needsDisplay = true
    }
    
    override func mouseExited (theEvent: NSEvent) {
        butCopyWidthConstraint?.constant = 0
        bgColor = NSColor.clearColor()
        butCopy!.needsLayout = true
        self.needsDisplay = true
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        self.ensureTrackingArea()
        if (!(self.trackingAreas as NSArray).containsObject(self.trackingArea!)) {
            self.addTrackingArea(self.trackingArea!);
        }
    }
    
    func ensureTrackingArea() {
        if (trackingArea == nil) {
            trackingArea = NSTrackingArea(
                rect: self.bounds,
                options: [NSTrackingAreaOptions.InVisibleRect, .ActiveAlways, .MouseEnteredAndExited],
                owner: self,
                userInfo: nil
            )
        }
    }
}
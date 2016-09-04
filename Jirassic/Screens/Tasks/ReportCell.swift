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
}

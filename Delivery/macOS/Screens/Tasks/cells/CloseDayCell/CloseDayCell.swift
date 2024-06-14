//
//  CloseDayCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa

class CloseDayCell: NSTableRowView {
    
    @IBOutlet private var butAdd: NSButton!
    @IBOutlet private var butCloseDay: NSButton!
    
    var didClickAddTask: (() -> Void)?
    var didClickCloseDay: (() -> Void)?
    
    @IBAction func handleAddButton (_ sender: NSButton) {
        didClickAddTask?()
    }
    
    @IBAction func handleCloseDayButton (_ sender: NSButton) {
        didClickCloseDay?()
    }
    
}

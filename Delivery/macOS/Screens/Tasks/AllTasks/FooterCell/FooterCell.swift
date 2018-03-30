//
//  FooterCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class FooterCell: NSTableRowView {

    @IBOutlet fileprivate var butAdd: NSButton!
    @IBOutlet fileprivate var butEnd: NSButton!
    @IBOutlet fileprivate var butWorklogs: NSButton!

    var didAddTask: (() -> Void)?
    var didEndDay: (() -> Void)?
    var isDayEnded: Bool? {
        didSet {
            self.butAdd.isHidden = isDayEnded!
            self.butEnd.isHidden = isDayEnded!
            self.butWorklogs.isHidden = !isDayEnded!
        }
    }
    
    override func draw (_ dirtyRect: NSRect) {
        NSColor.clear.set()
        dirtyRect.fill()
    }
    
    @IBAction func handleAddButton (_ sender: NSButton) {
        didAddTask?()
    }
    
    @IBAction func handleEndButton (_ sender: NSButton) {
        didEndDay?()
    }
}

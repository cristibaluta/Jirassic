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
    private var bgColor = NSColor.clear

    var didAddTask: (() -> Void)?
    var didEndDay: (() -> Void)?
    var isDayEnded: Bool? {
        didSet {
            self.butEnd.title = isDayEnded == true ? "Worklogs" : "End day"
        }
    }
    
    override func draw (_ dirtyRect: NSRect) {
        bgColor.set()
        dirtyRect.fill()
    }
    
    @IBAction func handleAddButton (_ sender: NSButton) {
        didAddTask?()
    }
    
    @IBAction func handleEndButton (_ sender: NSButton) {
        didEndDay?()
    }
}

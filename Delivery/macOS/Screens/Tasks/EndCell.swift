//
//  ShareCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class EndCell: NSTableRowView {
    
    var statusImage: NSImageView?
    @IBOutlet fileprivate var statusTextField: NSTextField?
    @IBOutlet fileprivate var butEnd: NSButton?
    @IBOutlet fileprivate var butShare: NSButton?
    @IBOutlet fileprivate var progressIndicator: NSProgressIndicator!
    fileprivate var bgColor: NSColor = NSColor.clear
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw (_ dirtyRect: NSRect) {
        bgColor.set()
        dirtyRect.fill()
    }
    
    @IBAction func handleShareButton (_ sender: NSButton) {
        
    }
    
    @IBAction func handleEndButton (_ sender: NSButton) {
        
    }
}

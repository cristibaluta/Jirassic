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
//    @IBOutlet fileprivate var statusTextField: NSTextField?
    @IBOutlet fileprivate var butAdd: NSButton?
    @IBOutlet fileprivate var butEnd: NSButton?
    @IBOutlet fileprivate var progressIndicator: NSProgressIndicator!
    fileprivate var bgColor: NSColor = NSColor.clear

    var didAddTask: (() -> Void)?
    var didEndDay: ((_ shouldSaveToJira: Bool, _ shouldRoundTime: Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw (_ dirtyRect: NSRect) {
        bgColor.set()
        dirtyRect.fill()
    }
    
    @IBAction func handleAddButton (_ sender: NSButton) {
        didAddTask?()
    }
    
    @IBAction func handleEndButton (_ sender: NSButton) {
        didEndDay?(true, true)
    }

    func showProgressIndicator (_ show: Bool) {
        if show {
            progressIndicator.startAnimation(nil)
        } else {
            progressIndicator.stopAnimation(nil)
        }
    }
}

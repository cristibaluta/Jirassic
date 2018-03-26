//
//  JirassicCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class JirassicCell: NSTableRowView {
    
    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var textField: NSTextField!
    @IBOutlet fileprivate var butInstall: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setJirassicStatus (available: Bool, compatible: Bool) {
        
        if available {
            statusImageView.image = NSImage(named: compatible
                ? NSImage.Name.statusAvailable
                : NSImage.Name.statusPartiallyAvailable)
            textField.stringValue = compatible
                ? "Run 'jirassic' in Terminal for more info"
                : "Jirassic cmd is outdated or uninstalled, please install!"
        } else {
            statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            textField.stringValue = "Install shell support first!"
        }
        butInstall.isHidden = available && compatible
    }
    
    func save() {
        
    }
    
    @IBAction func handleInstallButton (_ sender: NSButton) {
        #if APPSTORE
            NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
            //            presenter?.installJirassic()
            NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #endif
    }
    
}


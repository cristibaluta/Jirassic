//
//  ShellCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class ShellCell: NSTableRowView {
    
    static let height = CGFloat(60)
    
    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var textField: NSTextField!
    @IBOutlet fileprivate var butInstall: NSButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setShellStatus (available: Bool, compatible: Bool) {
        
        if available {
            statusImageView.image = NSImage(named: compatible
                ? NSImage.Name.statusAvailable
                : NSImage.Name.statusPartiallyAvailable)
            textField.stringValue = compatible
                ? "Installed, Jirassic is now able to communicate with the outside world"
                : "Outdated, please update!"
        } else {
            statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            textField.stringValue = "Not installed yet"
        }
        butInstall.isHidden = available && compatible
    }
    
    func save() {
        // Nothing to save
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

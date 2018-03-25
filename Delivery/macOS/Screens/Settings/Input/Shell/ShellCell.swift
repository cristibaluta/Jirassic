//
//  ShellCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class ShellCell: NSTableRowView {

    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var textField: NSTextField!
    @IBOutlet fileprivate var butInstall: NSButton!

    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func setShellStatus (compatible: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            statusImageView.image = NSImage(named: compatible
                ? NSImage.Name.statusAvailable
                : NSImage.Name.statusPartiallyAvailable)
            textField.stringValue = compatible
                ? "Shell support installed"
                : "Applescript outdated"
        } else {
            statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            textField.stringValue = "Not installed yet"
        }
        butInstall.isHidden = scriptInstalled && compatible
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

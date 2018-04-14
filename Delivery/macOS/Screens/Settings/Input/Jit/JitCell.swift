//
//  JitCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class JitCell: NSTableRowView {

    static let height = CGFloat(135)
    
    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var textField: NSTextField!
    @IBOutlet fileprivate var butInstall: NSButton!

    fileprivate let localPreferences = RCPreferences<LocalPreferences>()

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    func save() {

    }
    
    func setJitStatus (available: Bool, compatible: Bool) {
        
        if available {
            statusImageView.image = NSImage(named: compatible
                ? NSImage.Name.statusAvailable
                : NSImage.Name.statusPartiallyAvailable)
            
            textField.stringValue = compatible
                ? "Installed, run 'jit' in Terminal for more info"
                : "Applescript installed but 'jit' CLI is outdated/uninstalled"
        } else {
            statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            textField.stringValue = "Install shell support first!"
        }
        butInstall.isHidden = available && compatible
    }

    @IBAction func handleInstallButton (_ sender: NSButton) {
        #if APPSTORE
            NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
            //            presenter?.installJit()
            NSWorkspace.shared.open( URL(string: "https://github.com/ralcr/Jit")!)
        #endif
    }
}


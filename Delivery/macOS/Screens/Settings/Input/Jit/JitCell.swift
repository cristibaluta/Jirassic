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
    
    @IBOutlet private var statusImageView: NSImageView!
    @IBOutlet private var textField: NSTextField!
    @IBOutlet private var butInstall: NSButton!
    @IBOutlet private var butEnable: NSButton!

    private let prefs = RCPreferences<LocalPreferences>()

    override func awakeFromNib() {
        super.awakeFromNib()
        butEnable.isHidden = true
        statusImageView.isHidden = false
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
                : "Jit is outdated or not installed, please install the latest version!"
            
            butEnable.state = prefs.bool(.enableJit) ? .on : .off
        } else {
            statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            textField.stringValue = "Cannot determine Jit compatibility, install shell support first!"
        }
        butInstall.isHidden = available && compatible
        butEnable.isHidden = !(available && compatible)
        statusImageView.isHidden = available && compatible
    }

    @IBAction func handleInstallButton (_ sender: NSButton) {
        #if APPSTORE
            NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
            //            presenter?.installJit()
            NSWorkspace.shared.open( URL(string: "https://github.com/ralcr/Jit")!)
        #endif
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        prefs.set(sender.state == .on, forKey: .enableJit)
    }
}


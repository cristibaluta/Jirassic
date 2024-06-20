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
    
    @IBOutlet private var statusImageView: NSImageView!
    @IBOutlet private var textField: NSTextField!
    @IBOutlet private var butInstall: NSButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.toolTip = "Shell scripts are needed for communicating with the plugins: reading git logs, reading browser url, finding compatibility."
    }

    func setShellStatus (compatibility: Compatibility) {
        
        if compatibility.available {
            statusImageView.image = NSImage(named: compatibility.compatible
                ? NSImage.statusAvailableName
                : NSImage.statusPartiallyAvailableName)
            textField.stringValue = compatibility.compatible
                ? "Version \(compatibility.currentVersion) installed, Jirassic is now able to communicate with the shell."
                : "Outdated, please update!"
        } else {
            statusImageView.image = NSImage(named: NSImage.statusUnavailableName)
            textField.stringValue = "Not installed yet"
        }
        butInstall.isHidden = compatibility.available && compatibility.compatible
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

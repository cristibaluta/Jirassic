//
//  GitCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class GitCell: NSTableRowView, Saveable {

    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var statusTextField: NSTextField!
    @IBOutlet fileprivate var emailsTextField: NSTextField!
    @IBOutlet fileprivate var pathsTextField: NSTextField!
    @IBOutlet fileprivate var butInstall: NSButton!

    fileprivate let localPreferences = RCPreferences<LocalPreferences>()

    override func awakeFromNib() {
        super.awakeFromNib()
        emailsTextField.stringValue = localPreferences.string(.settingsGitAuthors)
        pathsTextField.stringValue = localPreferences.string(.settingsGitPaths)
    }
    
    func setGitStatus (commandInstalled: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            statusImageView.image = NSImage(named: commandInstalled
                ? NSImage.Name.statusAvailable
                : NSImage.Name.statusPartiallyAvailable)
            statusTextField.stringValue = commandInstalled
                ? "Git installed"
                : "Git is not installed"
        } else {
            statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            statusTextField.stringValue = "Not possible to use git, install shell!"
        }
        butInstall.isHidden = scriptInstalled && commandInstalled
    }
    
    func save() {
        localPreferences.set(emailsTextField.stringValue, forKey: .settingsGitAuthors)
        localPreferences.set(pathsTextField.stringValue, forKey: .settingsGitPaths)
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

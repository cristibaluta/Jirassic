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
    @IBOutlet fileprivate var butEnable: NSButton!
    @IBOutlet fileprivate var statusTextField: NSTextField!
    @IBOutlet fileprivate var emailsTextField: NSTextField!
    @IBOutlet fileprivate var pathsTextField: NSTextField!
    @IBOutlet fileprivate var butInstall: NSButton!

    fileprivate let localPreferences = RCPreferences<LocalPreferences>()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        emailsTextField.stringValue = localPreferences.string(.settingsGitAuthors)
        pathsTextField.stringValue = localPreferences.string(.settingsGitPaths)
        butEnable.state = localPreferences.bool(.enableGit) ? .on : .off
    }
    
    func setGitStatus (commandInstalled: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            statusImageView.image = NSImage(named: commandInstalled
                ? NSImage.Name.statusAvailable
                : NSImage.Name.statusPartiallyAvailable)
            statusTextField.stringValue = commandInstalled
                ? "Commits made with git will appear in Jirassic as tasks."
                : "Git is not installed"
        } else {
            statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            statusTextField.stringValue = "Not possible to use git, please install shell support first!"
        }
        butInstall.isHidden = scriptInstalled && commandInstalled
        emailsTextField.isEnabled = scriptInstalled && commandInstalled
        pathsTextField.isEnabled = scriptInstalled && commandInstalled
        butEnable.isEnabled = scriptInstalled && commandInstalled
    }
    
    func save() {
        localPreferences.set(emailsTextField.stringValue, forKey: .settingsGitAuthors)
        localPreferences.set(pathsTextField.stringValue, forKey: .settingsGitPaths)
    }
    
    @IBAction func handleInstallButton (_ sender: NSButton) {
        #if APPSTORE
            NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
            NSWorkspace.shared.open( URL(string: "https://github.com/ralcr/Jit")!)
        #endif
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        localPreferences.set(sender.state == .on, forKey: .enableGit)
    }
}

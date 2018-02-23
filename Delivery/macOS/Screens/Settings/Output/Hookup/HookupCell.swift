//
//  HookupCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 31/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class HookupCell: NSTableRowView, Saveable {
    
    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var statusTextField: NSTextField!
    @IBOutlet fileprivate var butEnable: NSButton!
    @IBOutlet fileprivate var hookupNameTextField: NSTextField!
    
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hookupNameTextField.stringValue = localPreferences.string(.settingsHookupCmdName)
        butEnable.state = localPreferences.bool(.enableHookup) ? .on : .off
    }
    
    func save() {
        localPreferences.set(hookupNameTextField.stringValue, forKey: .settingsHookupCmdName)
    }
    
    
    func setHookupStatus (commandInstalled: Bool, scriptInstalled: Bool) {
        
        if scriptInstalled {
            statusImageView.image = NSImage(named: commandInstalled
                ? NSImage.Name.statusAvailable
                : NSImage.Name.statusPartiallyAvailable)
            statusTextField.stringValue = commandInstalled
                ? "Start/End day actions will be sent to this cmd"
                : "Cmd does not exist"
        } else {
            statusImageView.image = NSImage(named: NSImage.Name.statusUnavailable)
            statusTextField.stringValue = "Not possible to use custom cmd, please install shell support first!"
        }
        hookupNameTextField.isEnabled = scriptInstalled
        butEnable.isEnabled = scriptInstalled
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        localPreferences.set(sender.state == .on, forKey: .enableHookup)
    }
}

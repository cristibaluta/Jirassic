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
    @IBOutlet fileprivate var textField: NSTextField!
    @IBOutlet fileprivate var butInstall: NSButton!
    @IBOutlet fileprivate var hookupNameTextField: NSTextField!
    
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hookupNameTextField.stringValue = localPreferences.string(.settingsHookupCmdName)
    }
    
    func save() {
        localPreferences.set(hookupNameTextField.stringValue, forKey: .settingsHookupCmdName)
    }
}

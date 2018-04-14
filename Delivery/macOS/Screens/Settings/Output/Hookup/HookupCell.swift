//
//  HookupCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 31/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class HookupCell: NSTableRowView, Saveable {
    
    static let height = CGFloat(160)
    
    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var statusTextField: NSTextField!
    @IBOutlet fileprivate var butEnable: NSButton!
    @IBOutlet fileprivate var hookupNameTextField: NSTextField!
    @IBOutlet fileprivate var butEnableCredentials: NSButton!
    @IBOutlet fileprivate var butPick: NSButton!
    
    var presenter: HookupPresenterInput = HookupPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hookupNameTextField.delegate = self
        (presenter as! HookupPresenter).userInterface = self
    }
    
    func save() {
        // Already saved
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        presenter.enableHookup(sender.state == .on)
    }
    
    @IBAction func handleEnableCredentialsButton (_ sender: NSButton) {
        presenter.enableCredentials(sender.state == .on)
    }
    
    @IBAction func handlePickButton (_ sender: NSButton) {
        presenter.pickCLI()
    }
}

extension HookupCell: HookupPresenterOutput {
    
    func setStatusImage (_ imageName: NSImage.Name) {
        statusImageView.image = NSImage(named: imageName)
    }
    func setStatusText (_ text: String) {
        statusTextField.stringValue = text
    }
    func setButEnable (on: Bool?, enabled: Bool?) {
        if let isOn = on {
            butEnable.title = isOn ? "Enabled" : "Disabled"
            butEnable.state = isOn ? .on : .off
        }
        if let enabled = enabled {
            butEnable.isEnabled = enabled
        }
    }
    func setButEnableCredentials (on: Bool?, enabled: Bool?) {
        if let isOn = on {
            butEnableCredentials.state = isOn ? .on : .off
        }
        if let enabled = enabled {
            butEnableCredentials.isEnabled = enabled
        }
    }
    func setButPick (enabled: Bool) {
        butPick.isEnabled = enabled
    }
    func setCommand (path: String?, enabled: Bool?) {
        if let path = path {
            hookupNameTextField.stringValue = path
        }
        if let enabled = enabled {
            hookupNameTextField.isEnabled = enabled
        }
    }
}

extension HookupCell: NSTextFieldDelegate {
    
    override func controlTextDidEndEditing (_ obj: Notification) {
        presenter.refresh(withCommand: hookupNameTextField.stringValue)
    }
}

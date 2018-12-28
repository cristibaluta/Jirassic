//
//  CocoaHookupCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class CocoaHookupCell: NSTableRowView, Saveable {
    
    static let height = CGFloat(95)
    
    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var statusTextField: NSTextField!
    @IBOutlet fileprivate var butEnable: NSButton!
    @IBOutlet fileprivate var hookupNameTextField: NSTextField!
    @IBOutlet fileprivate var butPick: NSButton!
    
    var presenter: CocoaHookupPresenterInput = CocoaHookupPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hookupNameTextField.delegate = self
        (presenter as! CocoaHookupPresenter).userInterface = self
    }
    
    func save() {
        // Already saved
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        presenter.enableCocoaHookup(sender.state == .on)
    }
    
    @IBAction func handlePickButton (_ sender: NSButton) {
        presenter.pickApp()
    }
}

extension CocoaHookupCell: CocoaHookupPresenterOutput {
    
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
    func setButPick (enabled: Bool) {
        butPick.isEnabled = enabled
    }
    func setApp (appName: String?, enabled: Bool?) {
        if let appName = appName {
            hookupNameTextField.stringValue = appName
        }
        if let enabled = enabled {
            hookupNameTextField.isEnabled = enabled
        }
    }
}

extension CocoaHookupCell: NSTextFieldDelegate {
    
    func controlTextDidEndEditing (_ obj: Notification) {
        presenter.refresh(withApp: hookupNameTextField.stringValue)
    }
}


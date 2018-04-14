//
//  GitCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class GitCell: NSTableRowView, Saveable {

    static let height = CGFloat(195)
    
    @IBOutlet fileprivate var statusImageView: NSImageView!
    @IBOutlet fileprivate var butEnable: NSButton!
    @IBOutlet fileprivate var statusTextField: NSTextField!
    @IBOutlet fileprivate var emailsTextField: NSTextField!
    @IBOutlet fileprivate var pathsTextField: NSTextField!
    @IBOutlet fileprivate var butInstall: NSButton!
    @IBOutlet fileprivate var butPick: NSButton!

    var presenter: GitPresenterInput = GitPresenter()

    override func awakeFromNib() {
        super.awakeFromNib()
        (presenter as! GitPresenter).userInterface = self
        butEnable.isHidden = true
        emailsTextField.delegate = self
        pathsTextField.delegate = self
    }
    
    func save() {
        presenter.save(emails: emailsTextField.stringValue, paths: pathsTextField.stringValue)
    }
    
    @IBAction func handleInstallButton (_ sender: NSButton) {
        #if APPSTORE
            NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
            NSWorkspace.shared.open( URL(string: "https://github.com/ralcr/Jit")!)
        #endif
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        presenter.enableGit(sender.state == .on)
    }
    
    @IBAction func handlePickButton (_ sender: NSButton) {
        presenter.pickPath()
    }
}

extension GitCell: NSTextFieldDelegate {
    
    override func controlTextDidEndEditing(_ obj: Notification) {
        save()
    }
}

extension GitCell: GitPresenterOutput {
    
    func setStatusImage (_ imageName: NSImage.Name) {
        statusImageView.image = NSImage(named: imageName)
    }
    func setStatusText (_ text: String) {
        statusTextField.stringValue = text
    }
    func setButInstall (enabled: Bool) {
        butInstall.isHidden = !enabled
        butEnable.isHidden = enabled
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
    func setPaths (_ paths: String?, enabled: Bool?) {
        if let paths = paths {
            pathsTextField.stringValue = paths
        }
        if let enabled = enabled {
            pathsTextField.isEnabled = enabled
            butPick.isEnabled = enabled
        }
    }
    func setEmails (_ emails: String?, enabled: Bool?) {
        if let emails = emails {
            emailsTextField.stringValue = emails
        }
        if let enabled = enabled {
            emailsTextField.isEnabled = enabled
        }
    }
}

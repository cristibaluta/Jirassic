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
    
    @IBOutlet private var statusImageView: NSImageView!
    @IBOutlet private var butEnable: NSButton!
    @IBOutlet private var statusTextField: NSTextField!
    @IBOutlet private var descriptionTextField: NSTextField!
    @IBOutlet private var emailsTextField: NSTextField!
    @IBOutlet private var pathsTextField: NSTextField!
    @IBOutlet private var butInstall: NSButton!
    @IBOutlet private var butPurchase: NSButton!
    @IBOutlet private var butPick: NSButton!

    var presenter: GitPresenterInput = GitPresenter()
    var onPurchasePressed: (() -> Void)?
    private var emailClickGestureRecognizer: NSClickGestureRecognizer?

    override func awakeFromNib() {
        super.awakeFromNib()
        (presenter as! GitPresenter).userInterface = self
        butEnable.isHidden = true
        butPurchase.isHidden = true
        emailsTextField.delegate = self
        pathsTextField.delegate = self
        
        let emailClickGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(GitCell.emailTextFieldClicked))
        emailsTextField.addGestureRecognizer(emailClickGestureRecognizer)
        self.emailClickGestureRecognizer = emailClickGestureRecognizer
    }
    
    deinit {
        if  let gesture = emailClickGestureRecognizer {
            emailsTextField.removeGestureRecognizer(gesture)
        }
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
    
    @IBAction func handlePurchaseButton (_ sender: NSButton) {
        onPurchasePressed?()
    }
    
    @IBAction func handleEnableButton (_ sender: NSButton) {
        presenter.enableGit(sender.state == .on)
    }
    
    @IBAction func handlePickButton (_ sender: NSButton) {
        presenter.pickPath()
    }
    
    @objc func emailTextFieldClicked() {
        let popover = NSPopover()
        let view = GitUsersViewController.instantiateFromStoryboard("Components")
        view.onDone = {
            popover.performClose(nil)
            self.presenter.isShellScriptInstalled = true
        }
        popover.contentViewController = view
        popover.show(relativeTo: emailsTextField.frame, of: self, preferredEdge: NSRectEdge.maxY)
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
    func setDescriptionText (_ text: String) {
        descriptionTextField.stringValue = text
    }
    func setButInstall (enabled: Bool) {
        butInstall.isHidden = !enabled
    }
    func setButPurchase (enabled: Bool) {
        butPurchase.isHidden = !enabled
    }
    func setButEnable (on: Bool?, enabled: Bool?) {
        if let isOn = on {
            butEnable.state = isOn ? .on : .off
        }
        butEnable.isHidden = enabled == false
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

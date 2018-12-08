//
//  WizardGitView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class WizardGitView: NSView {
    
    @IBOutlet fileprivate var emailsTextField: NSTextField!
    @IBOutlet fileprivate var pathsTextField: NSTextField!
    @IBOutlet fileprivate var butPick: NSButton!
    @IBOutlet var butSkip: NSButton!
    var onSkip: (() -> Void)?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    var presenter: GitPresenterInput = GitPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Git is disabled by default, we need to enable in order to be able to make changes
        localPreferences.set(true, forKey: .enableGit)
        (presenter as! GitPresenter).userInterface = self
        presenter.isShellScriptInstalled = true
    }
    
    func save() {
        presenter.save(emails: emailsTextField.stringValue, paths: pathsTextField.stringValue)
    }
    
    @IBAction func handlePickButton (_ sender: NSButton) {
        presenter.pickPath()
    }
    
    @IBAction func handleSkipButton (_ sender: NSButton) {
        // If git was not setup completely, disable it
        if emailsTextField.stringValue == "" || pathsTextField.stringValue == "" {
            localPreferences.set(false, forKey: .enableGit)
        }
        save()
        onSkip?()
    }
}

extension WizardGitView: GitPresenterOutput {
    
    func setStatusImage (_ imageName: NSImage.Name) {}
    func setStatusText (_ text: String) {}
    func setDescriptionText (_ text: String) {}
    func setButInstall (enabled: Bool) {}
    func setButPurchase(enabled: Bool) {}
    func setButEnable (on: Bool?, enabled: Bool?) {}
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

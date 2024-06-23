//
//  WizardGitView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa
import RCPreferences

class WizardGitView: NSView {
    
    @IBOutlet fileprivate var emailsTextField: NSTextField!
    @IBOutlet fileprivate var pathsTextField: NSTextField!
    @IBOutlet fileprivate var butPick: NSButton!
    @IBOutlet var butSkip: NSButton!
    var onSkip: (() -> Void)?
    private let pref = RCPreferences<LocalPreferences>()
    
    var presenter: GitPresenterInput = GitPresenter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Git is disabled by default, we need to enable in order to be able to make changes
        pref.set(true, forKey: .enableGit)
        (presenter as! GitPresenter).userInterface = self
        presenter.isShellScriptInstalled = true
    }
    
    func save() {
        
    }
    
    @IBAction func handleSkipButton (_ sender: NSButton) {
        // If git was not setup completely, disable it
        if emailsTextField.stringValue == "" || pathsTextField.stringValue == "" {
            pref.set(false, forKey: .enableGit)
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
}

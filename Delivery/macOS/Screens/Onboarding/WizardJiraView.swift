//
//  WizardJiraView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class WizardJiraView: NSView {
    
    @IBOutlet var butLogin: NSButton!
    @IBOutlet var butSkip: NSButton!
    @IBOutlet fileprivate var baseUrlTextField: NSTextField!
    @IBOutlet fileprivate var userTextField: NSTextField!
    @IBOutlet fileprivate var passwordTextField: NSTextField!
    @IBOutlet fileprivate var errorTextField: NSTextField!
    @IBOutlet fileprivate var projectNamePopup: NSPopUpButton!
    @IBOutlet fileprivate var projectIssueNamePopup: NSPopUpButton!
    @IBOutlet fileprivate var progressIndicator: NSProgressIndicator!
    
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    var presenter: JiraTempoPresenterInput = JiraTempoPresenter()
    
    var onSkip: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseUrlTextField.stringValue = localPreferences.string(.settingsJiraUrl)
        userTextField.stringValue = localPreferences.string(.settingsJiraUser)
        passwordTextField.stringValue = Keychain.getPassword()
        
        projectNamePopup.target = self
        projectNamePopup.action = #selector(projectNamePopupSelected(_:))
        
        projectIssueNamePopup.target = self
        projectIssueNamePopup.action = #selector(projectIssueNamePopupSelected(_:))
        
        (presenter as! JiraTempoPresenter).userInterface = self
        presenter.setupUserInterface()
        handleLoginButton(butLogin)
    }
    
    func save() {
        presenter.save(url: baseUrlTextField.stringValue,
                       user: userTextField.stringValue,
                       password: passwordTextField.stringValue)
    }
    
    @IBAction func handleLoginButton (_ sender: NSButton) {
        save()
        guard baseUrlTextField.stringValue != "",
            userTextField.stringValue != "",
            passwordTextField.stringValue != "" else {
                return
        }
        presenter.checkCredentials()
    }
    
    @IBAction func handleSkipButton (_ sender: NSButton) {
        onSkip?()
    }

    @IBAction func projectNamePopupSelected (_ sender: NSPopUpButton) {
        if let title = sender.selectedItem?.title {
            localPreferences.set(title, forKey: .settingsJiraProjectKey)
            presenter.loadProjectIssues(for: title)
        }
    }

    @IBAction func projectIssueNamePopupSelected (_ sender: NSPopUpButton) {
        localPreferences.set(sender.selectedItem?.title ?? "", forKey: .settingsJiraProjectIssueKey)
    }
}

extension WizardJiraView: JiraTempoPresenterOutput {
    
    func setPurchased (_ purchased: Bool) {
        
    }
    
    func enableProgressIndicator (_ enabled: Bool) {
        enabled
            ? progressIndicator.startAnimation(nil)
            : progressIndicator.stopAnimation(nil)
        butLogin.isHidden = enabled
    }
    
    func showProjects (_ projects: [String], selectedProject: String) {
        projectNamePopup.removeAllItems()
        projectNamePopup.addItems(withTitles: projects)
        projectNamePopup.selectItem(withTitle: selectedProject)
    }
    
    func showProjectIssues (_ issues: [String], selectedIssue: String) {
        projectIssueNamePopup.removeAllItems()
        projectIssueNamePopup.addItems(withTitles: issues)
        projectIssueNamePopup.selectItem(withTitle: selectedIssue)
    }
    
    func showErrorMessage (_ message: String) {
        errorTextField.stringValue = message
    }
}

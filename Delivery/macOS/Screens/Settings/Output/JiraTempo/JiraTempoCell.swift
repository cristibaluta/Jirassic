//
//  JiraTempoCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 31/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa
import RCPreferences

class JiraTempoCell: NSTableRowView {
    
    static let height = CGFloat(250)
    
    @IBOutlet private var butPurchase: NSButton!
    @IBOutlet private var baseUrlTextField: NSTextField!
    @IBOutlet private var userTextField: NSTextField!
    @IBOutlet private var passwordTextField: NSTextField!
    @IBOutlet private var errorTextField: NSTextField!
    @IBOutlet private var projectNamePopup: NSPopUpButton!
    @IBOutlet private var projectIssueNamePopup: NSPopUpButton!
    @IBOutlet private var progressIndicator: NSProgressIndicator!
    
    private let pref = RCPreferences<LocalPreferences>()
    var presenter: JiraTempoPresenterInput = JiraTempoPresenter()
    var onPurchasePressed: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseUrlTextField.delegate = self
        userTextField.delegate = self
        passwordTextField.delegate = self
        
        baseUrlTextField.stringValue = pref.string(.settingsJiraUrl)
        userTextField.stringValue = pref.string(.settingsJiraUser)
        passwordTextField.stringValue = Keychain.getPassword()
        
        projectNamePopup.target = self
        projectNamePopup.action = #selector(JiraTempoCell.projectNamePopupSelected(_:))
        
        projectIssueNamePopup.target = self
        projectIssueNamePopup.action = #selector(JiraTempoCell.projectIssueNamePopupSelected(_:))
        
        (presenter as! JiraTempoPresenter).userInterface = self
        presenter.setupUserInterface()
        checkCredentials()
    }

    func checkCredentials() {
        let user = JiraUser(url: pref.string(.settingsJiraUrl),
                            user: pref.string(.settingsJiraUser),
                            password: Keychain.getPassword(),
                            project: pref.string(.settingsJiraProjectKey),
                            issue: pref.string(.settingsJiraProjectIssueKey))
        presenter.checkCredentials(user)
    }

    func save() {
        saveCredentialsToPref()
    }

    func saveCredentialsToPref() {
        pref.set(baseUrlTextField.stringValue, forKey: .settingsJiraUrl)
        pref.set(userTextField.stringValue, forKey: .settingsJiraUser)
        // Save password only if different than the existing one
        if passwordTextField.stringValue != Keychain.getPassword() {
            Keychain.setPassword(passwordTextField.stringValue)
        }
    }
    
    @IBAction func handlePurchaseButton (_ sender: NSButton) {
        onPurchasePressed?()
    }
    
    @IBAction func projectNamePopupSelected (_ sender: NSPopUpButton) {
        if let title = sender.selectedItem?.title {
            pref.set(title, forKey: .settingsJiraProjectKey)
            presenter.loadProjectIssues(for: title)
        }
    }
    
    @IBAction func projectIssueNamePopupSelected (_ sender: NSPopUpButton) {
        pref.set(sender.selectedItem?.title ?? "", forKey: .settingsJiraProjectIssueKey)
    }
}

extension JiraTempoCell: JiraTempoPresenterOutput {
    
    func setPurchased (_ purchased: Bool) {
        butPurchase.isHidden = purchased
        baseUrlTextField.isEnabled = purchased
        userTextField.isEnabled = purchased
        passwordTextField.isEnabled = purchased
        projectNamePopup.isEnabled = purchased
        projectIssueNamePopup.isEnabled = purchased
    }
    
    func enableProgressIndicator (_ enabled: Bool) {
        enabled
            ? progressIndicator.startAnimation(nil)
            : progressIndicator.stopAnimation(nil)
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

extension JiraTempoCell: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        guard baseUrlTextField.stringValue != "",
            userTextField.stringValue != "",
            passwordTextField.stringValue != "" else {
            /// Fields are empty
            saveCredentialsToPref()
            return
        }
        guard baseUrlTextField.stringValue != pref.string(.settingsJiraUrl) ||
            userTextField.stringValue != pref.string(.settingsJiraUser) ||
            passwordTextField.stringValue != Keychain.getPassword() else {
            /// No change to the fields
            return
        }
        saveCredentialsToPref()
        checkCredentials()
    }
}

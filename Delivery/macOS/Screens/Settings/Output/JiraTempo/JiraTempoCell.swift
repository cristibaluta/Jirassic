//
//  JiraTempoCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 31/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

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
    
    private let localPreferences = RCPreferences<LocalPreferences>()
    var presenter: JiraTempoPresenterInput = JiraTempoPresenter()
    var onPurchasePressed: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        baseUrlTextField.delegate = self
        userTextField.delegate = self
        passwordTextField.delegate = self
        
        baseUrlTextField.stringValue = localPreferences.string(.settingsJiraUrl)
        userTextField.stringValue = localPreferences.string(.settingsJiraUser)
        passwordTextField.stringValue = Keychain.getPassword()
        
        projectNamePopup.target = self
        projectNamePopup.action = #selector(JiraTempoCell.projectNamePopupSelected(_:))
        
        projectIssueNamePopup.target = self
        projectIssueNamePopup.action = #selector(JiraTempoCell.projectIssueNamePopupSelected(_:))
        
        (presenter as! JiraTempoPresenter).userInterface = self
        presenter.setupUserInterface()
        presenter.checkCredentials()
    }
    
    func save() {
        presenter.save(url: baseUrlTextField.stringValue,
                       user: userTextField.stringValue,
                       password: passwordTextField.stringValue)
    }
    
    @IBAction func handlePurchaseButton (_ sender: NSButton) {
        onPurchasePressed?()
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
            // Fields are empty
            save()
            return
        }
        guard baseUrlTextField.stringValue != localPreferences.string(.settingsJiraUrl) ||
            userTextField.stringValue != localPreferences.string(.settingsJiraUser) ||
            passwordTextField.stringValue != Keychain.getPassword() else {
            // No change to the fields
            return
        }
        save()
        presenter.checkCredentials()
    }
}

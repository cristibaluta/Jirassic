//
//  ProjectDetailsViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa

class ProjectDetailsViewController: NSViewController {
    
    @IBOutlet private var butCredentials: NSButton!
    @IBOutlet private var baseUrlTextField: NSTextField!
    @IBOutlet private var userTextField: NSTextField!
    @IBOutlet private var passwordTextField: NSTextField!
    @IBOutlet private var errorTextField: NSTextField!
    @IBOutlet private var projectNamePopup: NSPopUpButton!
    @IBOutlet private var projectIssueNamePopup: NSPopUpButton!
    @IBOutlet private var progressIndicator: NSProgressIndicator!
    @IBOutlet private var emailsTextField: NSTextField!
    @IBOutlet private var pathsTextField: NSTextField!
    @IBOutlet private var taskNumberPrefixTextField: NSTextField!
    @IBOutlet private var butPick: NSButton!
    @IBOutlet private var butSave: NSButton!
    @IBOutlet private var butDelete: NSButton!
    
    var project: Project? {
        didSet {
            presenter?.project = project
        }
    }
    var projectDidSave: ((Project) -> Void)?
    
    var presenter: ProjectDetailsPresenterInput?
    var jiraPresenter: JiraTempoPresenterInput = JiraTempoPresenter()
    
    private var emailClickGestureRecognizer: NSClickGestureRecognizer?
    private var gitUsersPopover: NSPopover?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseUrlTextField.delegate = self
        userTextField.delegate = self
        passwordTextField.delegate = self
        taskNumberPrefixTextField.delegate = self
        emailsTextField.delegate = self
        pathsTextField.delegate = self
        
        let gesture = NSClickGestureRecognizer(target: self, action: #selector(ProjectDetailsViewController.emailTextFieldClicked))
        emailsTextField.addGestureRecognizer(gesture)
        self.emailClickGestureRecognizer = gesture
    }
    
    deinit {
        if let gesture = emailClickGestureRecognizer {
            emailsTextField.removeGestureRecognizer(gesture)
        }
    }

    @IBAction func handlePickerButton (_ sender: NSButton) {
        pickPath()
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {

        /// Make a copy of the project. Directly editing the project will call reloadData for each change
        guard var project = self.project else {
            return
        }
        project.jiraBaseUrl = baseUrlTextField.stringValue
        project.jiraUser = userTextField.stringValue
        project.jiraProject = projectNamePopup.selectedItem?.title
        project.jiraIssue = projectIssueNamePopup.selectedItem?.title
        project.gitBaseUrls = pathsTextField.stringValue.toArray()
        project.gitUsers = emailsTextField.stringValue.toArray()
        project.taskNumberPrefix = taskNumberPrefixTextField.stringValue

        self.project = project

        presenter!.saveProject(project)
    }
    
    @IBAction func handleDeleteButton (_ sender: NSButton) {
        presenter!.deleteProject(project!)
    }
    
    @IBAction func handleCredentialsButton (_ sender: NSButton) {
        presenter!.enableDefaultCredentials(sender.state == .on)
    }
    
    @IBAction func projectNamePopupSelected (_ sender: NSPopUpButton) {
        if let title = sender.selectedItem?.title {
            presenter!.editedProject?.jiraProject = title
            jiraPresenter.loadProjectIssues(for: title)
        }
    }
    
    @IBAction func projectIssueNamePopupSelected (_ sender: NSPopUpButton) {
        presenter!.editedProject?.jiraIssue = sender.selectedItem?.title
    }
    
    @objc func emailTextFieldClicked() {
        guard gitUsersPopover == nil else {
            return
        }
        let popover = NSPopover()
        let view = GitUsersViewController.instantiateFromStoryboard("Components")
        view.onDone = {
            let emails = view.selectedUsers.toString()
            self.presenter?.save(emails: emails)
            self.gitUsersPopover?.performClose(nil)
            self.gitUsersPopover = nil
            self.emailsTextField.stringValue = emails
        }
        popover.contentViewController = view
        let rect = CGRect(origin: CGPoint(x: emailsTextField.frame.width/2, y: 0),
                          size: emailsTextField.frame.size)
        popover.show(relativeTo: rect, of: emailsTextField, preferredEdge: NSRectEdge.minY)
        gitUsersPopover = popover
        /// Set emails after popover is presented
        view.selectedUsers = presenter?.project?.gitUsers ?? []
    }
}

extension ProjectDetailsViewController: ProjectDetailsPresenterOutput {

    func show (_ project: Project) {

        butCredentials.state = project.jiraBaseUrl == nil ? .on : .off
        baseUrlTextField.stringValue = project.jiraBaseUrl ?? ""
        userTextField.stringValue = project.jiraUser ?? ""
        errorTextField.stringValue = ""
        projectNamePopup.removeAllItems()
        projectNamePopup.addItem(withTitle: project.jiraProject ?? "")
        projectIssueNamePopup.removeAllItems()
        projectIssueNamePopup.addItem(withTitle: project.jiraIssue ?? "")
        pathsTextField.stringValue = project.gitBaseUrls.toString()
        emailsTextField.stringValue = project.gitUsers.toString()
        taskNumberPrefixTextField.stringValue = project.taskNumberPrefix ?? ""
    }

    func pickPath() {
        
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select the root of the git project you want to track"
        panel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.maximumWindow)))
        panel.begin { [weak self] result in
            
            guard let url = panel.urls.first, result.rawValue == NSFileHandlingPanelOKButton else {
                return
            }
            self?.presenter?.didPickUrl(url)
        }
    }

    func setCredentialsCheckbox (enabled: Bool) {
        butCredentials.state = enabled ? .on : .off
    }

    func setCredentials (url: String, user: String, password: String, editable: Bool) {
        
        baseUrlTextField.stringValue = url
        userTextField.stringValue = user
        passwordTextField.stringValue = password
        baseUrlTextField.isEditable = editable
        userTextField.isEditable = editable
        passwordTextField.isEditable = editable
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
    
    func enableSaveButton (_ enable: Bool) {
        butSave.isEnabled = enable
    }
    
    func handleProjectDidSave (_ project: Project) {
        projectDidSave?(project)
    }
}

extension ProjectDetailsViewController: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        
        presenter!.editedProject?.jiraBaseUrl = baseUrlTextField.stringValue
        presenter!.editedProject?.jiraUser = userTextField.stringValue
        presenter!.editedProject?.gitBaseUrls = pathsTextField.stringValue.toArray()
//        project.gitUsers = emailsTextField.stringValue.toArray()
//        project.taskNumberPrefix = taskNumberPrefixTextField.stringValue
        presenter!.save(emails: emailsTextField.stringValue)
        presenter!.save(paths: pathsTextField.stringValue)
    }
}

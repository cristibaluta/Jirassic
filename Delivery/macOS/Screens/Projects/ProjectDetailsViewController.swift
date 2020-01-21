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
    @IBOutlet private var butDelete: NSButton!
    
    var project: Project? {
        didSet {
            reloadData()
        }
    }
    
    var presenter: ProjectDetailsPresenterInput?
    
    private var emailClickGestureRecognizer: NSClickGestureRecognizer?
    private var gitUsersPopover: NSPopover?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    func reloadData() {
        
        guard let project = project else {
            return
        }
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
        
    }
    
    @objc func emailTextFieldClicked() {
        guard gitUsersPopover == nil else {
            return
        }
        let popover = NSPopover()
        let view = GitUsersViewController.instantiateFromStoryboard("Components")
        view.onDone = {
            self.emailsTextField.stringValue = view.selectedUsers.joined(separator: ",")
            self.gitUsersPopover?.performClose(nil)
            self.gitUsersPopover = nil
        }
        popover.contentViewController = view
        let rect = CGRect(origin: CGPoint(x: emailsTextField.frame.width/2, y: 0),
                          size: emailsTextField.frame.size)
        popover.show(relativeTo: rect, of: emailsTextField, preferredEdge: NSRectEdge.minY)
        gitUsersPopover = popover
        // Set emails after popover is presented
        view.selectedUsers = ["cristi.baluta@gmail.com"]
    }
}

extension ProjectDetailsViewController: ProjectDetailsPresenterOutput {
    
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

extension ProjectDetailsViewController: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
//        save()
    }
}

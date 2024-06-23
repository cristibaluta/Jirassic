//
//  ProjectDetailsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 28/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences

protocol ProjectDetailsPresenterInput: class {

    var project: Project? {get set}
    var editedProject: Project? {get set}
    func enableDefaultCredentials(_ enabled: Bool)
    func didPickUrl (_ url: URL)
    func save (emails: String)
    func save (paths: String)
    func saveProject (_ project: Project)
    func deleteProject (_ project: Project)
}

protocol ProjectDetailsPresenterOutput: class {

    func pickPath()
    func show (_ project: Project)
    func setCredentialsCheckbox (enabled: Bool)
    func setCredentials (url: String, user: String, password: String, editable: Bool)
    func setPaths (_ paths: String?, enabled: Bool?)
    func setEmails (_ emails: String?, enabled: Bool?)
    func enableSaveButton (_ enable: Bool)
    func handleProjectDidSave (_ project: Project)
}

class ProjectDetailsPresenter {
    
    weak var ui: ProjectDetailsPresenterOutput?
    private let prefs = RCPreferences<LocalPreferences>()

    var project: Project? {
        didSet {
            editedProject = project
            reloadData()
        }
    }
    /// Do all changes on the copy
    var editedProject: Project? {
        didSet {
            enableDisableSave()
        }
    }
    
    private func enableDisableSave() {
        ui!.enableSaveButton(project != editedProject)
    }
}

extension ProjectDetailsPresenter: ProjectDetailsPresenterInput {
    
    func reloadData() {

        guard let project = project else {
            return
        }
        ui!.show(project)
        ui!.setPaths(project.gitBaseUrls.toString(), enabled: prefs.bool(.enableGit))
        ui!.setEmails(project.gitUsers.toString(), enabled: prefs.bool(.enableGit))
        enableDisableSave()

        let credentialsEnabled = (project.jiraBaseUrl ?? "") == "" && (project.jiraUser ?? "") == ""
        enableDefaultCredentials(credentialsEnabled)
        ui!.setCredentialsCheckbox(enabled: credentialsEnabled)
    }
    
    func enableDefaultCredentials(_ enabled: Bool) {
        
        if enabled {
            ui!.setCredentials(url: prefs.string(.settingsJiraUrl),
                               user: prefs.string(.settingsJiraUser),
                               password: "",
                               editable: false)
        } else {
            ui!.setCredentials(url: "", user: "", password: "", editable: true)
        }
    }
    
    func didPickUrl (_ url: URL) {

        guard var project = editedProject else {
            return
        }
        var path = url.absoluteString
        path = path.replacingOccurrences(of: "file://", with: "")
        path.removeLast()
        // TODO: Validate if the picked project is a git project
        
        var existingPaths = project.gitBaseUrls
        existingPaths.append(path)
        project.gitBaseUrls = existingPaths
        editedProject = project

        ui!.setPaths(existingPaths.toString(), enabled: prefs.bool(.enableGit))
    }
    
    func save (emails: String) {
        editedProject?.gitUsers = emails.toArray()
    }
    
    func save (paths: String) {
        editedProject?.gitBaseUrls = paths.toArray()
    }
    
    func saveProject (_ project: Project) {
//        if project.objectId == nil {
//
//        }
        let interactor = ProjectInteractor(repository: localRepository, remoteRepository: remoteRepository)
        interactor.saveProject(project, allowSyncing: true) { savedProject in
            guard let project = savedProject else {
                return
            }
            self.project = project
            self.enableDisableSave()
            self.ui!.handleProjectDidSave(project)
            self.enableDisableSave()
        }
    }

    func deleteProject (_ project: Project) {

    }
}

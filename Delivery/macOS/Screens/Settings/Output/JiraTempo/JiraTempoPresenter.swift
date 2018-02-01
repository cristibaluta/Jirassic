//
//  JiraTempoPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

protocol JiraTempoPresenterInput: class {
    
    func setupUserInterface()
    func loadProjects()
    func loadProjectIssues (for projectKey: String)
}

protocol JiraTempoPresenterOutput: class {
    
    func enableProgressIndicator (_ enabled: Bool)
    func showProjects (_ projects: [String], selectedProject: String)
    func showProjectIssues (_ issues: [String], selectedIssue: String)
}

class JiraTempoPresenter {
    
    weak var userInterface: JiraTempoPresenterOutput?
    fileprivate var jiraTempoInteractor = ModuleJiraTempo()
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
}

extension JiraTempoPresenter: JiraTempoPresenterInput {
    
    func setupUserInterface() {
        
        let selectedProjectName = localPreferences.string(.settingsJiraProjectKey)
        let projects = selectedProjectName != "" ? [selectedProjectName] : []
        userInterface!.showProjects(projects, selectedProject: selectedProjectName)
        
        let selectedProjectIssueName = localPreferences.string(.settingsJiraProjectIssueKey)
        let issues = selectedProjectIssueName != "" ? [selectedProjectIssueName] : []
        userInterface!.showProjectIssues(issues, selectedIssue: selectedProjectIssueName)
    }
    
    func loadProjects() {
        
        userInterface!.enableProgressIndicator(true)
        
        jiraTempoInteractor.fetchProjects { [weak self] (projects) in
            if let wself = self {
                let titles = projects.map { $0.key }
                DispatchQueue.main.async {
                    wself.userInterface!.enableProgressIndicator(false)
                    wself.userInterface!.showProjects(titles, selectedProject: wself.localPreferences.string(.settingsJiraProjectKey))
                }
            }
        }
    }
    
    func loadProjectIssues (for projectKey: String) {
        
        userInterface!.enableProgressIndicator(true)
        
        jiraTempoInteractor.fetchProjectIssues (projectKey: projectKey) { [weak self] (projects) in
            if let wself = self {
                let titles = projects.map { $0.key }
                DispatchQueue.main.async {
                    wself.userInterface!.enableProgressIndicator(false)
                    wself.userInterface!.showProjectIssues(titles, selectedIssue: wself.localPreferences.string(.settingsJiraProjectIssueKey))
                }
            }
        }
    }
}

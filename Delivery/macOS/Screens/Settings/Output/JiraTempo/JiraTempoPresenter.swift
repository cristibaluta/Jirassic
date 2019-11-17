//
//  JiraTempoPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences
import RCLog

protocol JiraTempoPresenterInput: class {
    
    func setupUserInterface()
    func checkCredentials()
    func loadProjects()
    func loadProjectIssues (for projectKey: String)
    func save (url: String, user: String, password: String)
}

protocol JiraTempoPresenterOutput: class {
    
    func setPurchased (_ purchased: Bool)
    func enableProgressIndicator (_ enabled: Bool)
    func showProjects (_ projects: [String], selectedProject: String)
    func showProjectIssues (_ issues: [String], selectedIssue: String)
    func showErrorMessage (_ message: String)
}

class JiraTempoPresenter {
    
    weak var userInterface: JiraTempoPresenterOutput?
    private var moduleJira = ModuleJiraTempo()
    private let store = Store.shared
    private let pref = RCPreferences<LocalPreferences>()
}

extension JiraTempoPresenter: JiraTempoPresenterInput {
    
    func checkCredentials() {
        loadProjects()
    }
    
    func setupUserInterface() {
        
        userInterface!.setPurchased(store.isJiraTempoPurchased)
        userInterface!.showErrorMessage("")
        
        let selectedProjectName = pref.string(.settingsJiraProjectKey)
        let projects = selectedProjectName != "" ? [selectedProjectName] : []
        userInterface!.showProjects(projects, selectedProject: selectedProjectName)
        
        let selectedProjectIssueName = pref.string(.settingsJiraProjectIssueKey)
        let issues = selectedProjectIssueName != "" ? [selectedProjectIssueName] : []
        userInterface!.showProjectIssues(issues, selectedIssue: selectedProjectIssueName)
    }
    
    func loadProjects() {
        
        // Start loading only if credentials are all setup, otherwise crashes will happen
        guard store.isJiraTempoPurchased && moduleJira.isConfigured else {
            return
        }
        userInterface!.enableProgressIndicator(true)
        userInterface!.showErrorMessage("")
        
        moduleJira.fetchProjects(success: { [weak self] (projects) in
            
            DispatchQueue.main.async {
                
                guard let wself = self, let userInterface = wself.userInterface else {
                    return
                }
                userInterface.enableProgressIndicator(false)
                
                let titles = projects.map { $0.key }
                let selectedProjectKey = wself.pref.string(.settingsJiraProjectKey)
                
                userInterface.showProjects(titles, selectedProject: selectedProjectKey)
                if projects.count > 0 && selectedProjectKey != "" {
                    wself.loadProjectIssues(for: selectedProjectKey)
                }
            }
            
        }, failure: { [weak self] (error) in
            
            DispatchQueue.main.async {
                self?.handleError(error)
            }
            
        })
    }
    
    func loadProjectIssues (for projectKey: String) {
        
        userInterface!.enableProgressIndicator(true)
        userInterface!.showErrorMessage("")
        
        moduleJira.fetchProjectIssues (projectKey: projectKey, success: { [weak self] (issues) in
            
            DispatchQueue.main.async {
                
                guard let wself = self, let userInterface = wself.userInterface else {
                    return
                }
                userInterface.enableProgressIndicator(false)
                let titles = issues.map { $0.key }
                userInterface.showProjectIssues(titles, selectedIssue: wself.pref.string(.settingsJiraProjectIssueKey))
            }
            
        }, failure: { [weak self] (error) in
            
            DispatchQueue.main.async {
                self?.handleError(error)
            }
            
        })
    }
    
    private func handleError(_ error: Error) {
        RCLog(error)
        var errorMessage = error.localizedDescription
        switch error._code {
        case -1001: errorMessage = "Server not reachable. Is your Jira limited to internal network?"
        case 1: errorMessage = "Unknown, please verify login via browser. Possible causes are wrong domain or you're using an expired password which is causing Jira to ask for captcha."
        default: errorMessage = error.localizedDescription
        }
        userInterface!.enableProgressIndicator(false)
        userInterface!.showErrorMessage("Error: \(errorMessage)")
    }
    
    func save (url: String, user: String, password: String) {
        
        pref.set(url, forKey: .settingsJiraUrl)
        pref.set(user, forKey: .settingsJiraUser)
        // Save password only if different than the existing one
        if password != Keychain.getPassword() {
            Keychain.setPassword(password)
        }
    }
}

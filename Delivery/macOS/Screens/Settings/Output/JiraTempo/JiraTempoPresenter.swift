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
    func checkCredentials (_ credentials: JiraUser)
    func loadProjects()
    func loadProjectIssues (for projectKey: String)
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
    private var credentials: JiraUser?
}

extension JiraTempoPresenter: JiraTempoPresenterInput {
    
    func checkCredentials (_ credentials: JiraUser) {
        self.credentials = credentials
        loadProjects()
    }
    
    func setupUserInterface() {
        
        userInterface!.setPurchased(store.isJiraTempoPurchased)
        userInterface!.showErrorMessage("")
        
        let selectedProjectName = credentials?.project ?? ""
        let projects = selectedProjectName != "" ? [selectedProjectName] : []
        userInterface!.showProjects(projects, selectedProject: selectedProjectName)
        
        let selectedProjectIssueName = credentials?.issue ?? ""
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
                let selectedProject = wself.credentials?.project ?? ""
                
                userInterface.showProjects(titles, selectedProject: selectedProject)
                if projects.count > 0 && selectedProject != "" {
                    wself.loadProjectIssues(for: selectedProject)
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
                let selectedIssue = wself.credentials?.issue ?? ""
                userInterface.showProjectIssues(titles, selectedIssue: selectedIssue)
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
}

//
//  JiraTempo.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class ModuleJiraTempo {
    
    let repository: JiraRepository!
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    
    init() {
        repository = JiraRepository(url: localPreferences.string(.settingsJiraUrl),
                                    user: localPreferences.string(.settingsJiraUser),
                                    password: localPreferences.string(.settingsJiraPassword))
    }
    
    func fetchProjects (completion: @escaping (([JProject]) -> Void)) {
        repository.fetchProjects(completion: completion)
    }
    
    func fetchProjectIssues (projectKey: String, completion: @escaping (([JProjectIssue]) -> Void)) {
        repository.fetchProjectIssues(projectKey: projectKey, completion: completion)
    }
    
    func upload (reports: [Report], date: Date) {
        
        let project = JProject(id: localPreferences.string(.settingsJiraProjectId),
                               key: localPreferences.string(.settingsJiraProjectKey),
                               name: "",
                               url: "")
        let projectIssue = JProjectIssue(id: "",
                                         key: localPreferences.string(.settingsJiraProjectIssueKey),
                                         url: "")
        
        repository.postReports(reports, in: project, to: projectIssue, date: date) {
            
        }
    }
}

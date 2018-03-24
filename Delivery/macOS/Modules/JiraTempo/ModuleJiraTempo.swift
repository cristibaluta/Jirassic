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
    var isReachable: Bool {
        return localPreferences.string(.settingsJiraUrl) != ""
            && localPreferences.string(.settingsJiraUser) != ""
            && Keychain.getPassword() != ""
            && localPreferences.string(.settingsJiraProjectKey) != ""
            && localPreferences.string(.settingsJiraProjectIssueKey) != ""
    }
    
    init() {
        repository = JiraRepository(url: localPreferences.string(.settingsJiraUrl),
                                    user: localPreferences.string(.settingsJiraUser),
                                    password: Keychain.getPassword())
    }
    
    func fetchProjects (completion: @escaping (([JProject]?) -> Void)) {
        repository.fetchProjects(completion: completion)
    }
    
    func fetchProjectIssues (projectKey: String, completion: @escaping (([JProjectIssue]?) -> Void)) {
        repository.fetchProjectIssues(projectKey: projectKey, completion: completion)
    }
    
    func upload (worklog: String, duration: Double, date: Date, completion: @escaping (_ success: Bool) -> Void) {
        
        let project = JProject(id: localPreferences.string(.settingsJiraProjectId),
                               key: localPreferences.string(.settingsJiraProjectKey),
                               name: "",
                               url: "")
        let projectIssue = JProjectIssue(id: "",
                                         key: localPreferences.string(.settingsJiraProjectIssueKey),
                                         url: "")

        repository.postWorklog(worklog, duration: duration, in: project, to: projectIssue, date: date) { success in
            completion(success)
        }
    }

//    func upload (reports: [Report]) {
//        var comment = ""
//        var duration = 0.0
//        for report in reports {
//            comment += report.taskNumber + " - " + report.title + "\n" + report.notes + "\n\n"
//            duration += report.duration
//        }
//    }
}

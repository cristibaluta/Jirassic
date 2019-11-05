//
//  JiraTempo.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences

class ModuleJiraTempo {
    
    private var repository: JiraRepository?
    private let pref = RCPreferences<LocalPreferences>()
    /// Returns true if credentials are all setup
    var isConfigured: Bool {
        return pref.string(.settingsJiraUrl) != ""
            && pref.string(.settingsJiraUser) != ""
            && Keychain.getPassword() != ""
    }
    var isProjectConfigured: Bool {
        return pref.string(.settingsJiraProjectKey) != ""
            && pref.string(.settingsJiraProjectIssueKey) != ""
    }
    
    func initRepository() {
        repository = JiraRepository(url: pref.string(.settingsJiraUrl),
                                    user: pref.string(.settingsJiraUser),
                                    password: Keychain.getPassword())
    }
    
    func fetchProjects (success: @escaping ([JProject]) -> Void, failure: @escaping (Error) -> Void) {
        initRepository()
        repository!.fetchProjects(success: success, failure: failure)
    }
    
    func fetchProjectIssues (projectKey: String, success: @escaping ([JProjectIssue]) -> Void, failure: @escaping (Error) -> Void) {
        initRepository()
        repository!.fetchProjectIssues(projectKey: projectKey, success: success, failure: failure)
    }
    
    func postWorklog (worklog: String,
                      duration: Double,
                      date: Date,
                      success: @escaping () -> Void,
                      failure: @escaping (Error) -> Void) {
        
        let project = JProject(id: pref.string(.settingsJiraProjectId),
                               key: pref.string(.settingsJiraProjectKey),
                               name: "",
                               url: "")
        let projectIssue = JProjectIssue(id: "",
                                         key: pref.string(.settingsJiraProjectIssueKey),
                                         url: "")

        initRepository()
        repository!.postWorklog(worklog, duration: duration, in: project, to: projectIssue, date: date, success: {
            success()
        }, failure: { error in
            failure(error)
        })
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

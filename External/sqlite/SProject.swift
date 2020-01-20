//
//  SProject.swift
//  Jirassic
//
//  Created by Cristian Baluta on 12/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation

class SProject: SQLTable {
    
    var objectId: String? = nil
    var lastModifiedDate: Date? = nil
    var markedForDeletion = false
    var title: String? = nil
    var jiraBaseUrl: String? = nil
    var jiraUser: String? = nil
    var jiraProject: String? = nil
    var jiraIssue: String? = nil
    
    var gitBaseUrls: String? = nil
    var gitUsers: String? = nil
    var taskNumberPrefix: String? = nil
    
    override func primaryKey() -> String {
        return "objectId"
    }
}

extension SProject {

    func toProject() -> Project {

        return Project(
            objectId: self.objectId,
            lastModifiedDate: self.lastModifiedDate,
            title: self.title ?? "",
            jiraBaseUrl: self.jiraBaseUrl,
            jiraUser: self.jiraUser,
            jiraProject: self.jiraProject,
            jiraIssue: self.jiraIssue,

            gitBaseUrls: (self.gitBaseUrls ?? "").toArray(),
            gitUsers: (self.gitBaseUrls ?? "").toArray(),
            taskNumberPrefix: self.taskNumberPrefix
        )
    }
}

extension Project {

    func toSProject() -> SProject {

        let sproject = SProject()
        sproject.objectId = self.objectId
        sproject.lastModifiedDate = self.lastModifiedDate
        sproject.title = self.title
        sproject.jiraBaseUrl = self.jiraBaseUrl
        sproject.jiraUser = self.jiraUser
        sproject.jiraProject = self.jiraProject
        sproject.jiraIssue = self.jiraIssue
        sproject.gitBaseUrls = self.gitBaseUrls.toString()
        sproject.gitUsers = self.gitUsers.toString()
        sproject.taskNumberPrefix = self.taskNumberPrefix

        return sproject
    }
}

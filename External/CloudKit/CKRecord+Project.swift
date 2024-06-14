//
//  CKRecord+Project.swift
//  Jirassic
//
//  Created by Cristian Baluta on 21/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit

extension CKRecord {

    func toProject() -> Project {

        return Project(
            objectId: self["objectId"] as? String,
            lastModifiedDate: self["lastModifiedDate"] as? Date,
            title: self["title"] as! String,
            jiraBaseUrl: self["jiraBaseUrl"] as? String,
            jiraUser: self["jiraUser"] as? String,
            jiraProject: self["jiraProject"] as? String,
            jiraIssue: self["jiraIssue"] as? String,
            gitBaseUrls: (self["gitBaseUrls"] as? String ?? "").toArray(),
            gitUsers: (self["gitUsers"] as? String ?? "").toArray(),
            taskNumberPrefix: self["taskNumberPrefix"] as? String
        )
    }

    func update (with project: Project) {

        self["objectId"] = project.objectId as CKRecordValue?
        self["lastModifiedDate"] = project.lastModifiedDate as CKRecordValue?
        self["title"] = project.title as CKRecordValue
        self["jiraBaseUrl"] = project.jiraBaseUrl as CKRecordValue?
        self["jiraUser"] = project.jiraUser as CKRecordValue?
        self["jiraProject"] = project.jiraProject as CKRecordValue?
        self["jiraIssue"] = project.jiraIssue as CKRecordValue?
        self["gitBaseUrls"] = project.gitBaseUrls.toString() as CKRecordValue?
        self["gitUsers"] = project.gitUsers.toString() as CKRecordValue?
        self["taskNumberPrefix"] = project.taskNumberPrefix as CKRecordValue?
    }
}

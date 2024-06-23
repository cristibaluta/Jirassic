//
//  Project.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/12/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

struct Project: Equatable {
    
    var objectId: String?
    var lastModifiedDate: Date?
    var title: String
    var jiraBaseUrl: String?
    var jiraUser: String?
    var jiraProject: String?
    var jiraIssue: String?
    
    var gitBaseUrls: [String]
    var gitUsers: [String]
    /// Git commits with this prefix are considered part of the project automatically
    var taskNumberPrefix: String?
}

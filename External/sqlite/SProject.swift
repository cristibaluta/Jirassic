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

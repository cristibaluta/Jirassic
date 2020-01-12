//
//  SqliteRepository+Projects.swift
//  Jirassic
//
//  Created by Cristian Baluta on 12/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation

extension SqliteRepository: RepositoryProjects {
    
    func projects() -> [Project] {
        return []
    }
    
    func queryProjects(_ completion: @escaping ((_ task: [Project]) -> Void)) {
        
    }
       
    func saveProject (_ project: Project, completion: @escaping ((_ task: Project?) -> Void)) {
        
    }
    
    func deleteProject (_ project: Project, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    private func projectFromSProject (_ sproject: SProject) -> Project {
        
        return Project(
            objectId: sproject.objectId,
            lastModifiedDate: sproject.lastModifiedDate,
            title: sproject.title ?? "",
            jiraBaseUrl: sproject.jiraBaseUrl,
            jiraUser: sproject.jiraUser,
            jiraProject: sproject.jiraProject,
            jiraIssue: sproject.jiraIssue,
            
            gitBaseUrls: (sproject.gitBaseUrls ?? "").toArray(),
            gitUsers: (sproject.gitBaseUrls ?? "").toArray(),
            taskNumberPrefix: sproject.taskNumberPrefix
        )
    }
    
    private func sprojectFromProject (_ project: Project) -> SProject {
        
        let sproject = SProject()
        sproject.objectId = project.objectId
        sproject.lastModifiedDate = project.lastModifiedDate
        sproject.title = project.title
        sproject.jiraBaseUrl = project.jiraBaseUrl
        sproject.jiraUser = project.jiraUser
        sproject.jiraProject = project.jiraProject
        sproject.jiraIssue = project.jiraIssue
        sproject.gitBaseUrls = project.gitBaseUrls.toString()
        sproject.gitUsers = project.gitUsers.toString()
        sproject.taskNumberPrefix = project.taskNumberPrefix
        
        return sproject
    }
}

//
//  ProjectsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 23/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Foundation

protocol ProjectsInteractorInput: class {

    func reloadProjects()
    func addProject()
    func removeProject (_ project: Project)
}

protocol ProjectsInteractorOutput: class {

    func projectsDidLoad (_ projects: [Project])
}

class ProjectsInteractor {
    
    weak var presenter: ProjectsPresenter?
    
}

extension ProjectsInteractor: ProjectsInteractorInput {

    func addProject() {
//        presenter?.projectsDidLoad([
//            
//        ])
    }
    
    func removeProject (_ project: Project) {
        
    }
    
    func reloadProjects() {
//        let interactor = ReadProjectsInteractor(repository: localRepository, remoteRepository: remoteRepository)
//        let projects = interactor.allProjects()
//        presenter?.projectsDidLoad(projects)

        presenter?.projectsDidLoad([
            Project(objectId: nil,
                    lastModifiedDate: nil,
                    title: "BoschEbike",
                    jiraBaseUrl: "https://jira.fortech.ro",
                    jiraUser: "cristianbal",
                    jiraProject: "BOSCH",
                    jiraIssue: "BOSCH-100",
                    gitBaseUrls: [],
                    gitUsers: ["cristi.baluta@gmail.com", "cristianbal@fortech.ro"],
                    taskNumberPrefix: "APP"),
            Project(objectId: nil,
                    lastModifiedDate: nil,
                    title: "Terma",
                    jiraBaseUrl: "https://jira.fortech.ro",
                    jiraUser: "cristianbal",
                    jiraProject: "TERMA",
                    jiraIssue: "TERMA-001",
                    gitBaseUrls: [],
                    gitUsers: [],
                    taskNumberPrefix: "TERMA")
        ])
    }
}

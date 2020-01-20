//
//  ProjectsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/12/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

protocol ProjectsPresenterInput: class {
    func reloadProjects()
    func addProject()
    func removeProject (_ project: Project)
}

protocol ProjectsPresenterOutput: class {
    func projectsDidLoad(_ projects: [Project])
    func showMessage (_ message: MessageViewModel)
    func hideMessage()
}

class ProjectsPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: ProjectsPresenterOutput?
    var interactor: ProjectsInteractorInput?
    
    private var projects = [Project]()
}

extension ProjectsPresenter: ProjectsPresenterInput {
    
    func reloadProjects() {
        interactor!.reloadProjects()
    }
    
    func addProject() {
        ui!.hideMessage()
//        interactor!.addProject()
        let newProject = Project(objectId: String.generateId(),
                                lastModifiedDate: nil,
                                title: "Project \(projects.count + 1)",
                                jiraBaseUrl: "https://",
                                jiraUser: nil,
                                jiraProject: nil,
                                jiraIssue: nil,
                                gitBaseUrls: [],
                                gitUsers: [],
                                taskNumberPrefix: nil)
        projects.append(newProject)
        projectsDidLoad(projects)
    }
    
    func removeProject (_ project: Project) {
//        interactor!.removeProject(project)
        let newProjects = projects.filter( { $0.title != project.title } )
        projectsDidLoad(newProjects)
    }
}

extension ProjectsPresenter: ProjectsInteractorOutput {
    
    func projectsDidLoad(_ projects: [Project]) {
        self.projects = projects
        if projects.count == 0 {
            ui!.showMessage((
                title: "No projects",
                message: "Add your first project!",
                buttonTitle: "Add"))
        } else {
            ui!.projectsDidLoad(projects)
        }
    }
}

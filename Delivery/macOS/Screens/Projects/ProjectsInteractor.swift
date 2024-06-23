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
}

protocol ProjectsInteractorOutput: class {

    func projectsDidLoad (_ projects: [Project])
}

class ProjectsInteractor {
    
    weak var presenter: ProjectsPresenter?
    
}

extension ProjectsInteractor: ProjectsInteractorInput {

    func reloadProjects() {
        let interactor = ReadProjectsInteractor(repository: localRepository, remoteRepository: remoteRepository)
        let projects = interactor.allProjects()
        presenter?.projectsDidLoad(projects)
    }
}

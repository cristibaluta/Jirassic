//
//  ProjectsViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/12/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class ProjectsViewController: NSSplitViewController {
    
    weak var appWireframe: AppWireframe?
    var presenter: ProjectsPresenterInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.focusRingType = .none
        self.splitViewItems.first?.minimumThickness = 120
        
        presenter!.reloadProjects()
    }
}

extension ProjectsViewController: ProjectsPresenterOutput {
    
    func showMessage (_ message: MessageViewModel) {
        
        let controller = appWireframe!.presentPlaceholder(message, in: self.view)
        controller.didPressButton = {
            self.presenter?.addProject()
        }
    }
    
    func hideMessage() {
        appWireframe!.removePlaceholder()
    }
    
    func hideProjects() {
        self.splitViewItems = []
    }
    
    func showProjects(_ projects: [Project]) {
        
        let projectsList = ProjectsListViewController.instantiateFromStoryboard("Projects")

        let projectDetails = ProjectDetailsViewController.instantiateFromStoryboard("Projects")
        let c2Presenter = ProjectDetailsPresenter()
        projectDetails.presenter = c2Presenter
        c2Presenter.ui = projectDetails

        let s1 = NSSplitViewItem(viewController: projectsList)
        s1.minimumThickness = 120
        let s2 = NSSplitViewItem(viewController: projectDetails)
        self.splitViewItems = [s1, s2]
        
        projectsList.projects = projects
        projectsList.didSelectProject = { project in
            projectDetails.project = project
        }
        projectsList.didUpdateProject = { project in
            /// In the list of projects only the title can change
            projectDetails.project?.title = project.title
        }
        projectsList.didSelectAddProject = {
            self.presenter?.addProject()
        }
        
        projectDetails.projectDidSave = { project in
            self.presenter!.updateProject(project)
        }
        
        if let firstProject = projects.first {
            projectsList.selectProject(firstProject)
            projectDetails.project = firstProject
        }
    }
}

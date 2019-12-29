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
    
    private func setupControllers() {
        
        guard self.splitViewItems.count == 0 else {
            return
        }
        let c1 = ProjectsListViewController.instantiateFromStoryboard("Projects")
        let c2 = ProjectDetailsViewController.instantiateFromStoryboard("Projects")
        let c2Presenter = ProjectDetailsPresenter()
        c2.presenter = c2Presenter
        c2Presenter.ui = c2
        let s1 = NSSplitViewItem(viewController: c1)
        s1.minimumThickness = 120
        let s2 = NSSplitViewItem(viewController: c2)
        self.splitViewItems = [s1, s2]
    }
}

extension ProjectsViewController: ProjectsPresenterOutput {
    
    func showMessage (_ message: MessageViewModel) {
        
        self.splitViewItems = []
        
        let controller = appWireframe!.presentPlaceholder(message, in: self.view)
        controller.didPressButton = {
            self.presenter?.addProject()
        }
    }
    
    func hideMessage() {
        appWireframe!.removePlaceholder()
    }
    
    func projectsDidLoad(_ projects: [Project]) {
        
        setupControllers()
        
        guard let controller = self.splitViewItems.first?.viewController as? ProjectsListViewController else {
            return
        }
        controller.projects = projects
        controller.didSelectProject = { project in
            
            guard let controller = self.splitViewItems.last?.viewController as? ProjectDetailsViewController else {
                return
            }
            controller.project = project
        }
        controller.didSelectAddProject = {
            self.presenter?.addProject()
        }
        controller.didSelectRemoveProject = { project in
            self.presenter?.removeProject(project)
        }
    }
}

//
//  ProjectDetailsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 28/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences

protocol ProjectDetailsPresenterInput: class {
    
    func didPickUrl (_ url: URL)
    func save (emails: String, paths: String)
    func saveProject (_ project: Project)
    func deleteProject (_ project: Project)
}

protocol ProjectDetailsPresenterOutput: class {
    
    func pickPath()
    func setPaths (_ paths: String?, enabled: Bool?)
    func setEmails (_ emails: String?, enabled: Bool?)
}

class ProjectDetailsPresenter {
    
    weak var ui: ProjectDetailsPresenterOutput?
    private let localPreferences = RCPreferences<LocalPreferences>()
    
}

extension ProjectDetailsPresenter: ProjectDetailsPresenterInput {
    
    func reloadData() {
        
        ui?.setPaths("",
                    enabled: localPreferences.bool(.enableGit))
        
        ui?.setEmails("",
                    enabled: localPreferences.bool(.enableGit))
        
    }
    
    func didPickUrl (_ url: URL) {
        
        var path = url.absoluteString
        path = path.replacingOccurrences(of: "file://", with: "")
        path.removeLast()
        // TODO: Validate if the picked project is a git project
        
//        let existingPaths = wself.localPreferences.string(.settingsGitPaths)
//        let updatedPaths = existingPaths == "" ? path : (existingPaths + "," + path)
//        savePaths(updatedPaths)
//        ui.setPaths(updatedPaths, enabled: localPreferences.bool(.enableGit))
    }
    
    func save (emails: String, paths: String) {
        saveEmails(emails)
        savePaths(paths)
    }
    
    func saveProject (_ project: Project) {
        if project.objectId == nil {
            
        }
        let interactor = ProjectInteractor(repository: localRepository, remoteRepository: remoteRepository)
        interactor.saveProject(project, allowSyncing: true) { savedProject in

        }
    }

    func deleteProject (_ project: Project) {

    }
    
    private func saveEmails (_ emails: String) {
        
    }
    
    private func savePaths (_ paths: String) {
        
    }
}

//
//  ProjectInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 12/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation

class ProjectInteractor: RepositoryInteractor {

//    func queryTask (withId objectId: String) -> Task? {
//        return repository.queryTask(withId: objectId)
//    }
    
    func saveProject (_ project: Project, allowSyncing: Bool, completion: @escaping (_ savedProject: Project?) -> Void) {
        
        guard project.objectId != nil else {
            fatalError("Cannot save a task without objectId")
        }
        var project = project
        project.lastModifiedDate = nil
        
        self.repository.saveProject(project, completion: { [weak self] savedProject in
            guard let localProject = savedProject else {
                completion(nil)
                return
            }
            if allowSyncing {
                // We don't care if the task doesn't get saved to server
                self?.syncProject(localProject, completion: { project in })
            }
            completion(localProject)
        })
    }
    
    func deleteProject (_ project: Project) {
        
        guard project.objectId != nil else {
            fatalError("Cannot delete a task without objectId")
        }
        self.repository.deleteProject(project, permanently: false, completion: { success in
            #if !CMD
            if let remoteRepository = self.remoteRepository {
                let sync = RCSync<Project>(localRepository: self.repository, remoteRepository: remoteRepository)
//                sync.deleteProject(project, completion: { success in })
            }
            #endif
        })
    }
    
    private func syncProject (_ project: Project, completion: @escaping (_ uploadedTask: Task) -> Void) {
        
        #if !CMD
        if let remoteRepository = self.remoteRepository {
            let sync = RCSync<Project>(localRepository: self.repository, remoteRepository: remoteRepository)
//            sync.uploadProject(project, completion: { (success) in
//                DispatchQueue.main.async {
//                    completion(project)
//                }
//            })
        }
        #endif
    }
}

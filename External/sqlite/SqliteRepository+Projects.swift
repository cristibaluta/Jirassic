//
//  SqliteRepository+Projects.swift
//  Jirassic
//
//  Created by Cristian Baluta on 12/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation
import RCLog

extension SqliteRepository: RepositoryProjects {
    
    func projects() -> [Project] {
        
        let projects: [SProject] = queryWithPredicate(nil, sortingKeyPath: nil)
        return projects.map({ $0.toProject() })
    }
    
    func queryProjects(_ completion: @escaping ((_ projects: [Project]) -> Void)) {
        completion(projects())
    }
    
    func saveProject (_ project: Project, completion: @escaping ((_ project: Project?) -> Void)) {

        let sproject = project.toSProject()
        let saved = sproject.save()
        #if !CMD
        RCLog("Project saved to sqlite \(saved) \(project)")
        #endif
        if saved == 1 {
            completion( sproject.toProject() )
        } else {
            completion(nil)
        }
    }
    
    func deleteProject (_ project: Project, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void)) {

        let sproject = project.toSProject()
        if permanently {
            completion( sproject.delete() )
        } else {
            sproject.markedForDeletion = true
            completion( sproject.save() == 1 )
        }
    }

    func deleteProject (objectId: String, completion: @escaping ((_ success: Bool) -> Void)) {

        let projectPredicate = "objectId == '\(objectId)'"
        let projects: [SProject] = queryWithPredicate(projectPredicate, sortingKeyPath: nil)
        if let sproject = projects.first {
            completion( sproject.delete() )
        } else {
            completion( false )
        }
    }
}

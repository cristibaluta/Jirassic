//
//  CoreDataRepository+Project.swift
//  Jirassic
//
//  Created by Cristian Baluta on 12/01/2020.
//  Copyright © 2020 Imagin soft. All rights reserved.
//

import Foundation

extension CoreDataRepository: RepositoryProjects {

    func projects() -> [Project] {
        return []
    }

    func queryProjects(_ completion: @escaping ((_ task: [Project]) -> Void)) {
        
    }
       
    func saveProject (_ project: Project, completion: @escaping ((_ task: Project?) -> Void)) {
        
    }

    func deleteProject (_ project: Project, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
}

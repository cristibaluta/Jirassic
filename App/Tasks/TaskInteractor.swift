//
//  TaskInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/10/15.
//  Copyright © 2017 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskInteractor: RepositoryInteractor {

    func saveTask (_ task: Task, completion: @escaping (_ savedTask: Task) -> Void) {
        
        self.repository.saveTask(task, completion: { (savedTask: Task) -> Void in
            
            if let remoteRepository = remoteRepository {
                let sync = SyncTasks(localRepository: self.repository, remoteRepository: remoteRepository)
                sync.saveTask(savedTask, completion: { (success) in
                    DispatchQueue.main.async {
                        completion(savedTask)
                    }
                })
            } else {
                completion(savedTask)
            }
        })
    }
    
    func deleteTask (_ task: Task) {
        
        self.repository.deleteTask(task, forceDelete: false, completion: { (success: Bool) -> Void in
            if let remoteRepository = remoteRepository {
                let sync = SyncTasks(localRepository: self.repository, remoteRepository: remoteRepository)
                sync.deleteTask(task, completion: { (success) in
                    
                })
            }
        })
    }
}

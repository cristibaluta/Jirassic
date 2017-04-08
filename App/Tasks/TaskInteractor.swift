//
//  TaskInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/10/15.
//  Copyright © 2017 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskInteractor: RepositoryInteractor {

    func saveTask (_ task: Task) {
        
        self.repository.saveTask(task, completion: { (savedTask: Task) -> Void in
            if let remoteRepository = remoteRepository {
                let sync = SyncTasks(localRepository: self.repository, remoteRepository: remoteRepository)
                sync.saveTask(savedTask, completion: { (success) in
                    
                })
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
    
//    fileprivate func sync() {
//        
//        if let remoteRepository = remoteRepository {
//            let sync = SyncTasks(localRepository: self.repository, remoteRepository: remoteRepository)
//            sync.start { hasIncomingChanges in
//                
//            }
//        }
//    }
}

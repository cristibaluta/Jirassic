//
//  AddTask.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/10/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskInteractor: RepositoryInteractor {

    func saveTask (_ task: Task) {
        
        self.repository.saveTask(task, completion: { (savedTask: Task) -> Void in
//            self.remoteRepository?.saveTask(savedTask, completion: { (task: Task) -> Void in
//                
//            })
//            self.sync()
            if let remoteRepository = remoteRepository {
                let sync = SyncTasks(localRepository: self.repository, remoteRepository: remoteRepository)
                sync.syncTask(savedTask, completion: { (success) in
                    
                })
            }
        })
        
    }
    
    func deleteTask (_ task: Task) {
        
        self.repository.deleteTask(task, completion: { (success: Bool) -> Void in
            self.sync()
        })
//        remoteRepository?.deleteTask(task, completion: { (success: Bool) -> Void in
//            
//        })
    }
    
    fileprivate func sync() {
        
        if let remoteRepository = remoteRepository {
            let sync = SyncTasks(localRepository: self.repository, remoteRepository: remoteRepository)
            sync.start { hasIncomingChanges in
                
            }
        }
    }
}

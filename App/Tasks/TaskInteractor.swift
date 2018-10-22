//
//  TaskInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/10/15.
//  Copyright © 2017 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskInteractor: RepositoryInteractor {

    func saveTask (_ task: Task, allowSyncing: Bool, completion: @escaping (_ savedTask: Task) -> Void) {
        
        var task = task
        task.lastModifiedDate = nil
        
        self.repository.saveTask(task, completion: { [weak self] (savedTask: Task) -> Void in
            if allowSyncing {
                self?.syncTask(savedTask, completion: { (task) in })
            }
            completion(savedTask)
        })
    }
    
    func deleteTask (_ task: Task) {
        
        self.repository.deleteTask(task, permanently: false, completion: { (success: Bool) -> Void in
            #if !CMD
            if let remoteRepository = self.remoteRepository {
                let sync = RCSync<Task>(localRepository: self.repository, remoteRepository: remoteRepository)
                sync.deleteTask(task, completion: { (success) in
                    
                })
            }
            #endif
        })
    }
    
    private func syncTask (_ task: Task, completion: @escaping (_ uploadedTask: Task) -> Void) {
        
        #if !CMD
        if let remoteRepository = self.remoteRepository {
            let sync = RCSync<Task>(localRepository: self.repository, remoteRepository: remoteRepository)
            sync.saveTask(task, completion: { (success) in
                DispatchQueue.main.async {
                    completion(task)
                }
            })
        }
        #endif
    }
}

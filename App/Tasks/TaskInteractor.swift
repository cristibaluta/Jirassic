//
//  TaskInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/10/15.
//  Copyright © 2017 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskInteractor: RepositoryInteractor {

    func queryTask (withId objectId: String) -> Task? {
        return repository.queryTask(withId: objectId)
    }
    
    func saveTask (_ task: Task, allowSyncing: Bool, completion: @escaping (_ savedTask: Task?) -> Void) {
        
        guard task.objectId != nil else {
            fatalError("Cannot save a task without objectId")
        }
        var task = task
        task.lastModifiedDate = nil
        
        self.repository.saveTask(task, completion: { [weak self] savedTask in
            guard let localTask = savedTask else {
                completion(nil)
                return
            }
            if allowSyncing {
                // We don't care if the task doesn't get saved to server
                self?.syncTask(localTask, completion: { (task) in })
            }
            completion(localTask)
        })
    }
    
    func deleteTask (_ task: Task) {
        
        guard task.objectId != nil else {
            fatalError("Cannot delete a task without objectId")
        }
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

//
//  SyncTasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation

class SyncTasks {
    
    fileprivate let localRepository: Repository!
    fileprivate let remoteRepository: Repository!
    fileprivate  var tasksToSync = [Task]()
    
    init (localRepository: Repository, remoteRepository: Repository) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }
    
    func start (_ completion: @escaping ((_ hasIncomingChanges: Bool) -> Void)) {
        
        tasksToSync = localRepository.queryUnsyncedTasks()
        RCLog("1. unsyncedTasks = \(tasksToSync.count)")
        syncNextTask { (success) in
            self.getLatestServerChanges(completion)
        }
    }
    
    fileprivate func syncNextTask (_ completion: ((_ success: Bool) -> Void)?) {
        
        guard tasksToSync.count > 0 else {
            completion?(true)
            return
        }
        let task = tasksToSync[0]
        tasksToSync.remove(at: 0)
        syncTask(task, completion: { (success) in
            self.syncNextTask(completion)
        })
    }
    
    func syncTask (_ task: Task, completion: ((_ success: Bool) -> Void)?) {
        
        RCLog("sync \(task)")
        _ = remoteRepository.saveTask(task) { (uploadedTask) in
            // After task was saved to server update it to local datastore
            _ = self.localRepository.saveTask(uploadedTask, completion: { (task) in
                completion?(true)
            })
        }
    }
    
    func getLatestServerChanges (_ completion: @escaping ((_ hasIncomingChanges: Bool) -> Void)) {
        RCLog("2. getLatestServerChanges")
        remoteRepository.queryChangedTasks(sinceDate: Date(timeIntervalSince1970: 0)) { tasks, error in
            for task in tasks {
                self.localRepository.saveTask(task, completion: { (task) in
                    RCLog("saved")
                })
            }
            completion(tasks.count > 0)
        }
    }
}

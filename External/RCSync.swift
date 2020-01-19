//
//  SyncTasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import RCLog

class RCSync<T> {
    
    private let localRepository: Repository!
    private let remoteRepository: Repository!
    private var objectsToUpload = [Task]()
    private var objectsToDelete = [Task]()
    
    init (localRepository: Repository, remoteRepository: Repository) {
        self.localRepository = localRepository
        self.remoteRepository = remoteRepository
    }
    
    func start (_ completion: @escaping ((_ hasIncomingChanges: Bool) -> Void)) {
        
        RCLog("1. Start iCloud sync")
        guard objectsToUpload.count == 0 || objectsToDelete.count == 0 else {
            RCLog("1. Sync already in progress, not starting it again")
            return
        }
        let lastSyncDate = ReadMetadataInteractor().tasksLastSyncDate()
        objectsToUpload = localRepository.queryUnsyncedTasks(since: lastSyncDate)
        RCLog("1. Nr of unsynced tasks: \(objectsToUpload.count)")
        localRepository.queryDeletedTasks { deletedTasks in
            RCLog("1. Nr of deleted tasks: \(deletedTasks.count)")
            self.objectsToDelete = deletedTasks
            self.syncNext { (success) in
                self.getLatestServerChanges(completion)
            }
        }
    }
    
    // Send to CloudKit the changes recursivelly then call the completion block
    private func syncNext (_ completion: @escaping ((_ success: Bool) -> Void)) {
        
        var task = objectsToUpload.first
        if task != nil {
            objectsToUpload.remove(at: 0)
            uploadTask(task!, completion: { success, lastSyncDate in
                self.syncNext(completion)
            })
        } else {
            task = objectsToDelete.first
            if task != nil {
                objectsToDelete.remove(at: 0)
                deleteTask(task!, completion: { success in
                    self.syncNext(completion)
                })
            } else {
                completion(true)
            }
        }
    }
    
    func uploadTask (_ task: Task, completion: @escaping ((_ success: Bool, _ lastSyncDate: Date?) -> Void)) {
        
        RCLog("1.1 >>> Save \(task)")
        _ = remoteRepository.saveTask(task) { uploadedTask in
            guard let uploadedTask = uploadedTask else {
                completion(false, nil)
                return
            }
            RCLog("1.1 Save <<< uploadedTask \(String(describing: uploadedTask.objectId))")
            // After task was saved to server update it to local datastore
            _ = self.localRepository.saveTask(uploadedTask, completion: { savedTask in
//                // If task was saved locally successful update the last sync date
//                // Otherwise last sync date will be an older date than the tasks last modified date
//                if let savedTask = savedTask {
//                    UserDefaults.standard.lastSyncDateWithRemote = savedTask.lastModifiedDate
//                }
                completion(savedTask != nil, savedTask?.lastModifiedDate)
            })
        }
    }
    
    func deleteTask (_ task: Task, completion: @escaping ((_ success: Bool) -> Void)) {
        
        RCLog("1.1 Delete \(task)")
        _ = remoteRepository.deleteTask(task, permanently: true) { (uploadedTask) in
            // After task was marked as deleted to server, delete it permanently from local db
            _ = self.localRepository.deleteTask(task, permanently: true, completion: { (task) in
                completion(true)
            })
        }
    }
    
    private func getLatestServerChanges (_ completion: @escaping ((_ hasIncomingChanges: Bool) -> Void)) {
        
        RCLog("2. Request latest server changes")
        remoteRepository.queryUpdates { changedTasks, deletedTasksIds, error in
            RCLog("2. Number of changes: \(changedTasks.count)")
            for task in changedTasks {
                self.localRepository.saveTask(task, completion: { (task) in
                    RCLog("2. Saved to local db \(String(describing: task?.objectId))")
                })
            }
            RCLog("2. Number of deletes: \(deletedTasksIds.count)")
            for remoteId in deletedTasksIds {
                self.localRepository.deleteTask(objectId: remoteId, completion: { (success) in
                    RCLog("2. Deleted from local db: \(remoteId) \(success)")
                })
            }
            completion(changedTasks.count > 0 || deletedTasksIds.count > 0)
        }
    }
}

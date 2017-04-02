//
//  CloudKitRepository+Tasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit

extension CloudKitRepository: RepositoryTasks {
    
    func queryTasks (_ page: Int, completion: ([Task], NSError?) -> Void) {
        let changeToken = UserDefaults.standard.serverChangeToken
        fetchChangedRecords(token: changeToken)
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        return []
    }
    
    func queryUnsyncedTasks() -> [Task] {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryChangedTasks (sinceDate: Date) -> [Task] {
        fatalError()
    }
    
    func deleteTask (_ taskToDelete: Task, completion: @escaping ((_ success: Bool) -> Void)) {
        
        var indexToRemove = -1
        var shouldRemove = false
        for task in tasks {
            indexToRemove += 1
            if task.objectId == taskToDelete.objectId {
                shouldRemove = true
                //                ptaskOfTask(task, completion: { (ptask: PTask) -> Void in
                //                    ptask.deleteEventually()
                //                    completion(success: true)
                //                })
                break
            }
        }
        if shouldRemove {
            self.tasks.remove(at: indexToRemove)
        }
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ success: Bool) -> Void)) -> Task {
        RCLogO("Update task \(task)")
        // Update local array
//        for i in 0..<tasks.count {
//            if task.objectId == tasks[i].objectId {
//                tasks[i] = task
//                break
//            }
//        }
        
        // Query for the task from server if exists
        cktaskOfTask(task) { (record) in
            var cktask: CKRecord? = record
            if record == nil {
                cktask = CKRecord(recordType: "Task", zoneID: self.customZone.zoneID)
            }
            cktask?["startDate"] = task.startDate as CKRecordValue?
            cktask?["endDate"] = task.endDate as CKRecordValue
            cktask?["notes"] = task.notes as CKRecordValue?
            cktask?["taskNumber"] = task.taskNumber as CKRecordValue?
            cktask?["taskType"] = task.taskType.rawValue as CKRecordValue
            cktask?["objectId"] = task.objectId as CKRecordValue
            
            self.privateDB.save(cktask!, completionHandler: { savedRecord, error in
                RCLogO(savedRecord)
                RCLogErrorO(error)
                completion(error != nil)
            }) 
        }
        return task
    }
}

extension CloudKitRepository {
    
    func cktaskOfTask (_ task: Task, completion: @escaping ((_ ctask: CKRecord?) -> Void)) {
        
        let predicate = NSPredicate(format: "objectId == %@", task.objectId as CVarArg)
        let query = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.perform(query, inZoneWith: customZone.zoneID) { (results: [CKRecord]?, error) in
            
            RCLogErrorO(error)
            
            if let result = results?.first {
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
}

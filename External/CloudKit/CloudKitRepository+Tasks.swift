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
    
    func queryTasks (_ page: Int, completion: @escaping ([Task], NSError?) -> Void) {
        let predicate = NSPredicate(value: true)
        fetchRecords(ofType: "Task", predicate: predicate) { (records) in
            completion(self.tasksFromCKTasks(records ?? []), nil)
        }
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        return []
    }
    
    func queryTasksInDay (_ day: Date, completion: @escaping ([Task], NSError?) -> Void) {
        let predicate = NSPredicate(format: "endDate >= %@ AND endDate <= %@", day.startOfDay() as CVarArg, day.endOfDay() as CVarArg)
        fetchRecords(ofType: "Task", predicate: predicate) { (records) in
            completion(self.tasksFromCKTasks(records ?? []), nil)
        }
    }
    
    func queryUnsyncedTasks() -> [Task] {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void) {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryChangedTasks (sinceDate: Date, completion: @escaping ([Task], NSError?) -> Void) {
        let changeToken = UserDefaults.standard.serverChangeToken
        fetchChangedRecords(token: changeToken, 
                            previousRecords: [], 
                            previousDeletedRecordsIds: [], 
                            completion: { (records, deletedRecordsIds) in
            completion(self.tasksFromCKTasks(records), nil)
        })
    }
    
    func deleteTask (_ task: Task, completion: @escaping ((_ success: Bool) -> Void)) {
        
        cktaskOfTask(task) { (record) in
            if let cktask = record {
            
                self.privateDB.delete(withRecordID: cktask.recordID, completionHandler: { (recordID, error) in
                    RCLogO(recordID)
                    RCLogErrorO(error)
                    completion(error != nil)
                })
            } else {
                completion(false)
            }
        }
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task) -> Void)) {
        RCLogO("Save to cloudkit \(task)")
        
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
                
                if let record = savedRecord {
                    let uploadedTask = self.taskFromCKTask(record)
                    completion(uploadedTask)
                }
            })
        }
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
    
    fileprivate func tasksFromCKTasks (_ cktasks: [CKRecord]) -> [Task] {
        
        var tasks = [Task]()
        for cktask in cktasks {
            tasks.append(self.taskFromCKTask(cktask))
        }
        
        return tasks
    }
    
    fileprivate func taskFromCKTask (_ cktask: CKRecord) -> Task {
        
        return Task(lastModifiedDate: cktask["modificationDate"] as? Date,
                    startDate: cktask["startDate"] as? Date,
                    endDate: cktask["endDate"] as! Date,
                    notes: cktask["notes"] as? String,
                    taskNumber: cktask["taskNumber"] as? String,
                    taskType: TaskType(rawValue: (cktask["taskType"] as! NSNumber).intValue)!,
                    objectId: cktask.recordID.recordName
        )
    }
    
}

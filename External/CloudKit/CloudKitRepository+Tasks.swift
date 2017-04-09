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
    
    func queryUpdates (sinceDate: Date, completion: @escaping ([Task], [String], NSError?) -> Void) {
        
        let changeToken = UserDefaults.standard.serverChangeToken
        
        fetchChangedRecords(token: changeToken, 
                            previousRecords: [], 
                            previousDeletedRecordsIds: [], 
                            completion: { (changedRecords, deletedRecordsIds) in
                                
            completion(self.tasksFromCKTasks(changedRecords), self.idsFromCKRecordIds(deletedRecordsIds), nil)
        })
    }
    
    func deleteTask (_ task: Task, forceDelete: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
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
    
    func deleteTask (objectId: String, completion: @escaping ((_ success: Bool) -> Void)) {
        
    }
    
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task) -> Void)) {
        RCLogO("Save to cloudkit \(task)")
        
        // Query for the task from server if exists
        cktaskOfTask(task) { (record) in
            var cktask: CKRecord? = record
            if record == nil {
                cktask = CKRecord(recordType: "Task", recordID: CKRecordID(recordName: task.objectId, zoneID: self.customZone.zoneID))
            }
            cktask?["startDate"] = task.startDate as CKRecordValue?
            cktask?["endDate"] = task.endDate as CKRecordValue
            cktask?["notes"] = task.notes as CKRecordValue?
            cktask?["taskNumber"] = task.taskNumber as CKRecordValue?
            cktask?["taskTitle"] = task.taskTitle as CKRecordValue?
            cktask?["taskType"] = task.taskType.rawValue as CKRecordValue
            cktask?["objectId"] = task.objectId as CKRecordValue
            
            self.privateDB.save(cktask!, completionHandler: { savedRecord, error in
                
                RCLog("Record after saved to ck")
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
            tasks.append( taskFromCKTask(cktask) )
        }
        
        return tasks
    }
    
    fileprivate func taskFromCKTask (_ cktask: CKRecord) -> Task {
        
        return Task(lastModifiedDate: cktask["modificationDate"] as? Date,
                    startDate: cktask["startDate"] as? Date,
                    endDate: cktask["endDate"] as! Date,
                    notes: cktask["notes"] as? String,
                    taskNumber: cktask["taskNumber"] as? String,
                    taskTitle: cktask["taskTitle"] as? String,
                    taskType: TaskType(rawValue: (cktask["taskType"] as! NSNumber).intValue)!,
                    objectId: cktask["objectId"] as! String
        )
    }
    
    fileprivate func idsFromCKRecordIds (_ ckrecords: [CKRecordID]) -> [String] {
        
        var ids = [String]()
        for ckrecord in ckrecords {
            ids.append( ckrecord.recordName )
        }
        
        return ids
    }
}

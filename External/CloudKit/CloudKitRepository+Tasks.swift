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
            completion(self.tasksFromRecords(records ?? []), nil)
        }
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        return []
    }
    
    func queryTasksInDay (_ day: Date, completion: @escaping ([Task], NSError?) -> Void) {
        let predicate = NSPredicate(format: "endDate >= %@ AND endDate <= %@", day.startOfDay() as CVarArg, day.endOfDay() as CVarArg)
        fetchRecords(ofType: "Task", predicate: predicate) { (records) in
            completion(self.tasksFromRecords(records ?? []), nil)
        }
    }
    
    func queryUnsyncedTasks() -> [Task] {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void) {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryUpdates (_ completion: @escaping ([Task], [String], NSError?) -> Void) {
        
        let changeToken = UserDefaults.standard.serverChangeToken
        
        fetchChangedRecords(token: changeToken, 
                            previousRecords: [], 
                            previousDeletedRecordsIds: [], 
                            completion: { (changedRecords, deletedRecordsIds) in
                                
            completion(self.tasksFromRecords(changedRecords), self.stringIdsFromCKRecordIds(deletedRecordsIds), nil)
        })
    }
    
    func deleteTask (_ task: Task, permanently: Bool, completion: @escaping ((_ success: Bool) -> Void)) {
        
        guard let privateDB = self.privateDB else {
            RCLog("Not logged in")
            return
        }
        
        recordOfTask(task) { (record) in
            if let cktask = record {
                
                privateDB.delete(withRecordID: cktask.recordID, completionHandler: { (recordID, error) in
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
        
        guard let customZone = self.customZone, let privateDB = self.privateDB else {
            RCLog("Not logged in")
            return
        }
        
        // Query for the task from server if exists
        recordOfTask(task) { (record) in
            var record: CKRecord? = record
            if record == nil {
                let recordId = CKRecordID(recordName: task.objectId, zoneID: customZone.zoneID)
                record = CKRecord(recordType: "Task", recordID: recordId)
            }
            record = self.updatedRecord(record!, withTask: task)
            
            privateDB.save(record!, completionHandler: { savedRecord, error in
                
                RCLog("Record after saved to ck")
                RCLogO(savedRecord)
                RCLogErrorO(error)
                
                if let record = savedRecord {
                    let uploadedTask = self.taskFromRecord(record)
                    completion(uploadedTask)
                }
            })
        }
    }
}

extension CloudKitRepository {
    
    func recordOfTask (_ task: Task, completion: @escaping ((_ ctask: CKRecord?) -> Void)) {
        
        guard let customZone = self.customZone, let privateDB = self.privateDB else {
            RCLog("Not logged in")
            return
        }
        
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
    
    fileprivate func tasksFromRecords (_ records: [CKRecord]) -> [Task] {
        
        var tasks = [Task]()
        for record in records {
            tasks.append( taskFromRecord(record) )
        }
        
        return tasks
    }
    
    fileprivate func taskFromRecord (_ record: CKRecord) -> Task {
        
        return Task(lastModifiedDate: record["modificationDate"] as? Date,
                    startDate: record["startDate"] as? Date,
                    endDate: record["endDate"] as! Date,
                    notes: record["notes"] as? String,
                    taskNumber: record["taskNumber"] as? String,
                    taskTitle: record["taskTitle"] as? String,
                    taskType: TaskType(rawValue: (record["taskType"] as! NSNumber).intValue)!,
                    objectId: record["objectId"] as! String
        )
    }
    
    fileprivate func updatedRecord (_ record: CKRecord, withTask task: Task) -> CKRecord {
        
        record["startDate"] = task.startDate as CKRecordValue?
        record["endDate"] = task.endDate as CKRecordValue
        record["notes"] = task.notes as CKRecordValue?
        record["taskNumber"] = task.taskNumber as CKRecordValue?
        record["taskTitle"] = task.taskTitle as CKRecordValue?
        record["taskType"] = task.taskType.rawValue as CKRecordValue
        record["objectId"] = task.objectId as CKRecordValue
        
        return record
    }
    
    fileprivate func stringIdsFromCKRecordIds (_ ckrecords: [CKRecordID]) -> [String] {
        
        var ids = [String]()
        for ckrecord in ckrecords {
            ids.append( ckrecord.recordName )
        }
        
        return ids
    }
}

//
//  CloudKitRepository+Tasks.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/04/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Foundation
import CloudKit
import RCLog

extension CloudKitRepository: RepositoryTasks {

    func queryTask (withId objectId: String) -> Task? {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryTasks (startDate: Date, endDate: Date, predicate: NSPredicate? = nil) -> [Task] {
        fatalError("This method is not applicable to CloudKitRepository")
    }

    func queryTasks (startDate: Date, endDate: Date, predicate: NSPredicate? = nil, completion: @escaping ([Task], NSError?) -> Void) {
        let predicate = NSPredicate(format: "endDate >= %@ AND endDate <= %@", startDate as CVarArg, endDate as CVarArg)
        tasksZone?.fetchRecords(ofType: "Task", predicate: predicate) { (records) in
            completion(self.tasksFromRecords(records ?? []), nil)
        }
    }
    
    func queryUnsyncedTasks(since lastSyncDate: Date?) -> [Task] {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryDeletedTasks (_ completion: @escaping ([Task]) -> Void) {
        fatalError("This method is not applicable to CloudKitRepository")
    }
    
    func queryUpdates (_ completion: @escaping ([Task], [String], NSError?) -> Void) {
        
        let changeToken = ReadMetadataInteractor().tasksLastSyncToken()
        
        tasksZone?.fetchChangedRecords(token: changeToken,
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
        
        fetchCKRecordOfTask(task) { (record) in
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
    
    func saveTask (_ task: Task, completion: @escaping ((_ task: Task?) -> Void)) {
        RCLogO("1. Save to cloudkit \(task)")
        
        guard let zoneId = self.tasksZone?.zoneId, let privateDB = self.privateDB else {
            RCLog("Can't save, not logged in to iCloud")
            return
        }
        
        // Query for the task from server if exists
        fetchCKRecordOfTask(task) { record in
            var record: CKRecord? = record
            // No record found on server, creating one now
            if record == nil {
                let recordId = CKRecord.ID(recordName: task.objectId!, zoneID: zoneId)
                record = CKRecord(recordType: "Task", recordID: recordId)
            }
            record = self.updatedRecord(record!, withTask: task)
            
            privateDB.save(record!, completionHandler: { savedRecord, error in
                
                RCLog("2. Saved to CloudKit \(String(describing: savedRecord))")
                RCLogErrorO(error)
                
                if let record = savedRecord {
                    let uploadedTask = self.taskFromRecord(record)
                    completion(uploadedTask)
                }
                if let ckerror = error as? CKError {
                    switch ckerror {
                    case CKError.quotaExceeded:
                        // The user has run out of iCloud storage space.
                        // Prompt the user to go to iCloud Settings to manage storage.
                        #warning("Present quotaExceeded message to the user")
                        break
                    default:
                        break
                    }
                    completion(nil)
                }
            })
        }
    }
}

extension CloudKitRepository {
    
    func fetchCKRecordOfTask (_ task: Task, completion: @escaping ((_ ctask: CKRecord?) -> Void)) {
        
        guard let zoneId = self.tasksZone?.zoneId, let privateDB = self.privateDB else {
            RCLog("Not logged in")
            return
        }
        
        let predicate = NSPredicate(format: "objectId == %@", task.objectId! as CVarArg)
        let query = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.perform(query, inZoneWith: zoneId) { (results: [CKRecord]?, error) in
            
            RCLogErrorO(error)
            
            if let result = results?.first {
                completion(result)
            } else {
                completion(nil)
            }
        }
    }
    
    private func tasksFromRecords (_ records: [CKRecord]) -> [Task] {
        return records.map({ taskFromRecord($0) })
    }
    
    private func taskFromRecord (_ record: CKRecord) -> Task {
        
        return Task(lastModifiedDate: record.modificationDate,
                    startDate: record["startDate"] as? Date,
                    endDate: record["endDate"] as! Date,
                    notes: record["notes"] as? String,
                    taskNumber: record["taskNumber"] as? String,
                    taskTitle: record["taskTitle"] as? String,
                    taskType: TaskType(rawValue: (record["taskType"] as! NSNumber).intValue)!,
                    objectId: record["objectId"] as? String,
                    projectId: record["projectId"] as? String
        )
    }
    
    private func updatedRecord (_ record: CKRecord, withTask task: Task) -> CKRecord {
        
        record["startDate"] = task.startDate as CKRecordValue?
        record["endDate"] = task.endDate as CKRecordValue
        record["notes"] = task.notes as CKRecordValue?
        record["taskNumber"] = task.taskNumber as CKRecordValue?
        record["taskTitle"] = task.taskTitle as CKRecordValue?
        record["taskType"] = task.taskType.rawValue as CKRecordValue
        record["objectId"] = task.objectId as CKRecordValue?
        record["projectId"] = task.projectId as CKRecordValue?
        
        return record
    }
    
    private func stringIdsFromCKRecordIds (_ ckrecords: [CKRecord.ID]) -> [String] {
        return ckrecords.map({ $0.recordName })
    }
}

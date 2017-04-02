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
        fetchChangedRecords(token: nil)
    }
    
    func queryTasksInDay (_ day: Date) -> [Task] {
        return []
    }
    
    func queryUnsyncedTasks() -> [Task] {
        fatalError("This method is not applicable to ParseRepository")
    }
    
    func deleteTask (_ taskToDelete: Task, completion: ((_ success: Bool) -> Void)) {
        
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
    
    func saveTask (_ task: Task, completion: ((_ success: Bool) -> Void)) -> Task {
        RCLogO("Update task \(task)")
        // Update local array
        for i in 0..<tasks.count {
            if task.objectId == tasks[i].objectId {
                tasks[i] = task
                break
            }
        }
        
        let ID = CKRecordID(recordName: task.objectId)
        let cktask = CKRecord(recordType: "Task", recordID: ID)
        cktask["lastModifiedDate"] = Date() as CKRecordValue?
        //        cktask["creationDate"] = task.creationDate as CKRecordValue?
        cktask["startDate"] = task.startDate as CKRecordValue?
        cktask["endDate"] = task.endDate as CKRecordValue
        cktask["notes"] = task.notes as CKRecordValue?
        cktask["taskNumber"] = task.taskNumber as CKRecordValue?
        cktask["taskType"] = task.taskType.rawValue as CKRecordValue
        cktask["objectId"] = task.objectId as CKRecordValue
        
        privateDB.save(cktask, completionHandler: { savedRecord, error in
            RCLogO(savedRecord)
            RCLogErrorO(error)
        }) 
        
        //        ptaskOfTask(task, completion: { (ptask: PTask) -> Void in
        //            // Update the ptask with data from task
        //            ptask.date_task_finished = task.endDate
        //            ptask.notes = task.notes
        //            ptask.issue_type = task.issueType
        //            ptask.issue_id = task.issueId
        //            ptask.task_type = task.taskType
        //            ptask.saveEventually { (success, error) -> Void in
        //                RCLogO("Saved to Parse \(success)")
        //                RCLogErrorO(error)
        //                completion(success: success)
        //            }
        //        })
        
        return task
    }
}

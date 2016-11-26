//
//  FirebaseRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/06/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitRepository {
    
    fileprivate var tasks = [Task]()
    fileprivate var user: User?
    let privateDB = CKContainer.default().privateCloudDatabase
    
    init() {
        CKContainer.default().accountStatus(completionHandler: { (status, error) in
            RCLog(status.rawValue)
            RCLogErrorO(error)
        })
    }
}

extension CloudKitRepository: Repository {

    func currentUser() -> User {
        
        if let user = self.user {
            return user
        }
        
//        if let puser = PUser.currentUser() {
//            self.user = User(isLoggedIn: true, email: puser.email, userId: puser.objectId, lastSyncDate: nil)
//        } else {
            self.user = User(isLoggedIn: false, email: nil, userId: nil, lastSyncDate: nil)
//        }
        
        return self.user!
    }
    
    func loginWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        
    }
    
    func registerWithCredentials (_ credentials: UserCredentials, completion: (NSError?) -> Void) {
        
    }
    
    func logout() {
        user = nil
    }
    
    func queryTasks (_ page: Int, completion: ([Task], NSError?) -> Void) {
        
        let predicate = NSPredicate(format: "TRUEPREDICATE")
        let query = CKQuery(recordType: "Task", predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { results, error in
            RCLogO(results)
            RCLogErrorO(error)
//            if error != nil {
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.delegate?.errorUpdating(error)
//                    return
//                }
//            } else {
//                self.items.removeAll(keepCapacity: true)
//                for record in results{
//                    let establishment = Establishment(record: record as! CKRecord, database: self.publicDB)
//                    self.items.append(establishment)
//                }
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.delegate?.modelUpdated()
//                    return
//                }
//            }
        }
//        let puser = PUser.currentUser()
//        let query = PFQuery(className: PTask.parseClassName())
//        query.limit = 200
//        query.whereKey(kUserKey, equalTo: puser!)
//        query.findObjectsInBackgroundWithBlock( { [weak self] (objects: [PFObject]?, error: NSError?) in
//            self?.processPTasks(objects, error: error, completion: completion)
//            })
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
            if task.taskId == taskToDelete.taskId {
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
            if task.taskId == tasks[i].taskId {
                tasks[i] = task
                break
            }
        }
        
        let ID = CKRecordID(recordName: task.taskId)
        let cktask = CKRecord(recordType: "Task", recordID: ID)
        cktask["notes"] = task.notes as CKRecordValue?
        
        privateDB.save(cktask, completionHandler: { savedRecord, error in
            RCLog(savedRecord)
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
    
    
    // MARK: Issue
    
    func queryIssues (_ successBlock: ([String]) -> Void, errorBlock: (NSError?) -> Void) {
        
        let issues = [String]()
        successBlock(issues)
    }
    
    func saveIssue (_ issue: String) {
        
    }
    
    // MARK: Settings
    
    func settings() -> Settings {
        fatalError("Not applicable")
    }
    
    func saveSettings (_ settings: Settings) {
        fatalError("Not applicable")
    }
}

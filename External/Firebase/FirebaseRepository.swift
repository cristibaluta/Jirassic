//
//  FirebaseRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/06/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

class FirebaseRepository {
    
    private var tasks = [Task]()
    private var user: User?
    
    init() {
//        assert(parseApplicationId != "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
//               "You need to create your own Parse app in order to use this. After that put the keys in ParseCredentials.swift")
        
//        PTask.registerSubclass()
//        PUser.registerSubclass()
//        PIssue.registerSubclass()
//        Parse.enableLocalDatastore()// This does not work with cache enabled
//        #if os(OSX)
//            PFUser.enableAutomaticUser()
//        #endif
//        
//        Parse.setApplicationId(parseApplicationId, clientKey:parseClientId)
//        
//        let acl = PFACL()
//        acl.publicReadAccess = false
//        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
//        
//        _ = PFAnalytics()
    }
}

extension FirebaseRepository: Repository {

    func currentUser() -> User {
        
        if let user = self.user {
            return user
        }
//        if let puser = PUser.currentUser() {
//            self.user = User(isLoggedIn: true, email: puser.email, userId: puser.objectId, lastSyncDate: nil)
//        } else {
//            self.user = User(isLoggedIn: false, email: nil, userId: nil, lastSyncDate: nil)
//        }
        
        return self.user!
    }
    
    func loginWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        
//        PUser.logInWithUsernameInBackground(credentials.email, password: credentials.password) {
//            [weak self] (user: PFUser?, error: NSError?) -> Void in
//            
//            if let user = user {
//                if let strongSelf = self {
//                    strongSelf.user = User(isLoggedIn: true, email: user.email, userId: user.objectId, lastSyncDate: nil)
//                }
//                completion(nil)
//            }
//            else if let error = error {
//                self?.user = nil
//                completion(error)
//            }
//        }
    }
    
    func registerWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        
//        let user = PFUser()
//        user.username = credentials.email
//        user.email = credentials.email
//        user.password = credentials.password
//        user.signUpInBackgroundWithBlock { (succeeded: Bool, error: NSError?) -> Void in
//            completion(error)
//        }
    }
    
    func logout() {
        user = nil
        PUser.logOutInBackgroundWithBlock { (error) -> Void in
            RCLog(error)
        }
    }
    
    func queryTasks (page: Int, completion: ([Task], NSError?) -> Void) {
        
//        let puser = PUser.currentUser()
//        let query = PFQuery(className: PTask.parseClassName())
//        query.limit = 200
//        query.whereKey(kUserKey, equalTo: puser!)
//        query.findObjectsInBackgroundWithBlock( { [weak self] (objects: [PFObject]?, error: NSError?) in
//            self?.processPTasks(objects, error: error, completion: completion)
//            })
    }
    
    func queryTasksInDay (day: NSDate) -> [Task] {
        return []
    }
    
    func queryUnsyncedTasks() -> [Task] {
        fatalError("This method is not applicable to ParseRepository")
    }
    
    func deleteTask (taskToDelete: Task, completion: ((success: Bool) -> Void)) {
        
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
            self.tasks.removeAtIndex(indexToRemove)
        }
    }
    
    func saveTask (task: Task, completion: ((success: Bool) -> Void)) -> Task {
        RCLogO("Update task \(task)")
        // Update local array
        for i in 0..<tasks.count {
            if task.taskId == tasks[i].taskId {
                tasks[i] = task
                break
            }
        }
        
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
    
    func queryIssues (successBlock: [String] -> Void, errorBlock: NSError? -> Void) {
        
        let issues = [String]()
        successBlock(issues)
    }
    
    func saveIssue (issue: String) {
        
    }
}

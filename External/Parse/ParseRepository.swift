//
//  DataManager.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

class ParseRepository {

	private var tasks = [Task]()
    private var user: User?
	
	init() {
        assert(parseApplicationId != "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
               "You need to create your own Parse app in order to use this. After that put the keys in ParseCredentials.swift")
        
        PTask.registerSubclass()
        PUser.registerSubclass()
        PIssue.registerSubclass()
        Parse.enableLocalDatastore()// This does not work with cache enabled
        #if os(OSX)
            PFUser.enableAutomaticUser()
        #endif
        
        Parse.setApplicationId(parseApplicationId, clientKey:parseClientId)
        
        let acl = PFACL()
        acl.publicReadAccess = false
        PFACL.setDefaultACL(acl, withAccessForCurrentUser: true)
        
        _ = PFAnalytics()
	}
}

extension ParseRepository {
    // Get the PTask corresponding to the Task. If doesn't exist, create one
    private func ptaskOfTask (task: Task, completion: ((ptask: PTask) -> Void)) {
        
        guard let taskId = task.taskId else {
            // PTask does not exist yet
            // TODO: insert it at the right index by comparing dates
            let ptask = taskToPTask(task)
            self.tasks.insert(task, atIndex: 0)
            completion(ptask: ptask)
            return
        }
        
        let query = PFQuery(className: PTask.parseClassName())
        query.fromLocalDatastore()
        query.getObjectInBackgroundWithId(taskId, block: { (data: PFObject?, error: NSError?) -> Void in
            
            if data == nil {
                let query = PFQuery(className: PTask.parseClassName())
                query.getObjectInBackgroundWithId(taskId, block: { (data: PFObject?, error: NSError?) -> Void in
                    
                    RCLogErrorO(error)
                    if data != nil {
                        completion(ptask: data as! PTask)
                    }
                })
            } else {
                completion(ptask: data as! PTask)
            }
        })
    }
    
    private func taskToPTask (task: Task) -> PTask {
        
        let ptask = PTask(className: PTask.parseClassName())
        ptask.date_task_started = task.startDate
        ptask.date_task_finished = task.endDate
        ptask.notes = task.notes
        ptask.issue_type = task.issueType
        ptask.issue_id = task.issueId
        ptask.task_type = task.taskType
        ptask.user = PUser.currentUser()
        
        return ptask
    }
    
    private func ptaskToTask (ptask: PTask) -> Task {
        
        return Task(startDate: ptask.date_task_started,
                    endDate: ptask.date_task_finished,
                    notes: ptask.notes,
                    issueType: ptask.issue_type,
                    issueId: ptask.issue_id,
                    taskType: ptask.task_type,
                    taskId: ptask.objectId)
    }
    
    private func processPTasks (objects: [PFObject]?, error: NSError?, completion: ([Task], NSError?) -> Void) {
        
        if error == nil && objects != nil {
            self.tasks = [Task]()
            for object in objects! {
                let ptask = object as! PTask
                self.tasks.append(self.ptaskToTask(ptask))
            }
        }
        completion(self.tasks, error)
    }
}

extension ParseRepository: Repository {
	
    func currentUser() -> User {
        
        if let user = self.user {
            return user
        }
        
        return User(isLoggedIn: false, email: nil, userId: nil)
    }
    
    func loginWithCredentials (credentials: UserCredentials, completion: (NSError?) -> Void) {
        
        PUser.logInWithUsernameInBackground(credentials.email, password: credentials.password) {
            [weak self] (user: PFUser?, error: NSError?) -> Void in
            
            if let user = user {
                if let strongSelf = self {
                    strongSelf.user = User(isLoggedIn: true, email: user.email, userId: user.objectId)
                }
                completion(nil)
            }
            else if let error = error {
                self?.user = nil
                completion(error)
            }
        }
    }
    
    func logout() {
        user = nil
        PUser.logOutInBackgroundWithBlock { (error) -> Void in
            RCLog(error)
        }
    }
    
	func queryTasks (completion: ([Task], NSError?) -> Void) {
		
		let puser = PUser.currentUser()
		let query = PFQuery(className: PTask.parseClassName())
        query.limit = 200
		query.whereKey(kUserKey, equalTo: puser!)
		query.findObjectsInBackgroundWithBlock( { [weak self] (objects: [PFObject]?, error: NSError?) in
            self?.processPTasks(objects, error: error, completion: completion)
		})
	}
    
    func queryTasksInDay (day: NSDate) -> [Task] {
        return []
    }
	
	func queryUnsyncedTasks() -> [Task] {
		return []
	}
	
    func deleteTask (taskToDelete: Task) {
        
        var indexToRemove = -1
        var shouldRemove = false
        for task in tasks {
            indexToRemove += 1
            if task.taskId == taskToDelete.taskId {
                shouldRemove = true
				ptaskOfTask(task, completion: { (ptask: PTask) -> Void in
					ptask.deleteEventually()
				})
                break
            }
        }
        if shouldRemove {
            self.tasks.removeAtIndex(indexToRemove)
        }
    }
	
	func saveTask (task: Task, completion: ((success: Bool) -> Void)) {
		RCLogO("Update task \(task)")
		// Update local array
		for i in 0..<tasks.count {
			if task.taskId == tasks[i].taskId {
				tasks[i] = task
				break
			}
		}
		// Update local and remote database
		ptaskOfTask(task, completion: { (ptask: PTask) -> Void in
			// Update the ptask with data from task
			ptask.date_task_started = task.startDate
			ptask.date_task_finished = task.endDate
			ptask.notes = task.notes
            ptask.issue_type = task.issueType
            ptask.issue_id = task.issueId
			ptask.task_type = task.taskType
            ptask.saveEventually { (success, error) -> Void in
                RCLogO("Saved to Parse \(success)")
                RCLogErrorO(error)
                completion(success: success)
            }
		})
	}
}

//
//  DataManager.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

class DataManager: NSObject, DataManagerProtocol {

	private var tasks = [Task]()
	
	override init() {
		_ = InitParse()
	}
	
	func queryTasks (completion: ([Task], NSError?) -> Void) {
		
		queryOfflineTasks(completion)
		queryOnlineTasks(completion)
	}
	
	private func queryOfflineTasks (completion: ([Task], NSError?) -> Void) {
		
		let query = PFQuery(className: PTask.parseClassName())
		query.fromLocalDatastore()
		query.findObjectsInBackgroundWithBlock( { [weak self] (objects: [PFObject]?, error: NSError?) in
			if let strongSelf = self {
				RCLogO("Found \(objects?.count) objects in LocalDatastore")
				strongSelf.processPTasks(objects, error: error, completion: completion)
			}
		})
	}
	
	private func queryOnlineTasks (completion: ([Task], NSError?) -> Void) {
		
		let puser = PUser.currentUser()
		let query = PFQuery(className: PTask.parseClassName())
		query.orderByDescending(kDateFinishKey)
		//		query.orderByDescending(kDateStartKey)
		query.whereKey("user", equalTo: puser!)
		query.findObjectsInBackgroundWithBlock( { [weak self] (objects: [PFObject]?, error: NSError?) in
			
			PFObject.pinAllInBackground(objects, block: { (success, error) -> Void in
				RCLogO("Pin \(objects?.count) objects \(success)")
				RCLogErrorO(error)
			})
			if let strongSelf = self {
				strongSelf.processPTasks(objects, error: error, completion: completion)
			}
		})
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
	
	func allCachedTasks() -> [Task] {
		return tasks
	}
	
    func deleteTask (taskToDelete: Task) {
        
        var indexToRemove = -1
        var shouldRemove = false
        for task in tasks {
            indexToRemove++
            if task.objectId == taskToDelete.objectId {
                shouldRemove = true
				ptaskOfTask(task, completion: { (ptask: PTask) -> Void in
					ptask.unpinInBackground()
					ptask.deleteEventually()
				})
                break
            }
        }
        if shouldRemove {
            self.tasks.removeAtIndex(indexToRemove)
        }
    }
	
	func updateTask (task: Task, completion: ((success: Bool) -> Void)) {
		RCLogO("Update task \(task)")
		// Update local array
		for i in 0...(tasks.count-1) {
			if task.objectId == tasks[i].objectId {
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
			ptask.task_type = task.taskType
			// Save it locally
			ptask.pinInBackgroundWithBlock { success, error in
				RCLogO("Saved to local Parse \(success)")
				RCLogErrorO(error)
				completion(success: true)
				
				// Save it to server
				ptask.saveEventually { (success, error) -> Void in
					RCLogO("Saved to Parse \(success)")
					RCLogErrorO(error)
				}
			}
		})
	}
	
	// Get the PTask corresponding to the Task. If doesn't exist, create one
	private func ptaskOfTask (task: Task, completion: ((ptask: PTask) -> Void)) {
		
		guard let objectId = task.objectId else {
			// Ptask does not exist yet
			// TODO: insert it at the right index by comparing dates
			let ptask = taskToPTask(task)
			self.tasks.insert(task, atIndex: 0)
			completion(ptask: ptask)
			return
		}
		
		let query = PFQuery(className: PTask.parseClassName())
		query.fromLocalDatastore()
		query.getObjectInBackgroundWithId(objectId, block: { (data: PFObject?, error: NSError?) -> Void in
			
			if data == nil {
				let query = PFQuery(className: PTask.parseClassName())
				query.getObjectInBackgroundWithId(objectId, block: { (data: PFObject?, error: NSError?) -> Void in
					
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
			ptask.task_type = task.taskType
			ptask.user = PUser.currentUser()
		
		return ptask
	}
	
	private func ptaskToTask (ptask: PTask) -> Task {
	
		return Task(startDate: ptask.date_task_started,
					endDate: ptask.date_task_finished,
					notes: ptask.notes,
					issueType: ptask.issue_type,
					taskType: ptask.task_type,
					objectId: ptask.objectId)
	}
}


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
	
	func queryTasks(completion: ([Task], NSError?) -> Void) {
		
		let puser = PUser.currentUser()
		let user = User(isLoggedIn: true, password: nil, email: puser?.email)
		RCLog(user)
		let query = PFQuery(className: PTask.parseClassName())
        query.cachePolicy = .CacheThenNetwork
		query.orderByDescending(kDateFinishKey)
		query.whereKey("user", equalTo: puser!)
		query.findObjectsInBackgroundWithBlock( { (objects: [PFObject]?, error: NSError?) in
			
			if error == nil && objects != nil {
				// Task does not conform to AnyObject
				// and as a side note the objc NSArray cannot be directly casted to Swift array
				self.tasks = [Task]()
				for object in objects! {
					let ptask = object as! PTask
					let task = Task(startDate: ptask.date_task_started,
						endDate: ptask.date_task_finished,
						notes: ptask.notes,
						issueType: ptask.issue_type,
						taskType: ptask.task_type, user: user)
					self.tasks.append(task)
				}
			}
			completion(self.tasks, error)
		})
	}
	
//	func read() {
//		
//		let query = PFQuery(className: PTask.parseClassName())
//		/*query.findObjectsInBackgroundWithBlock {
//		(objects: Array<AnyObject>!, error: NSError!) -> Void in
//		RCLogO(objects!)
//		for obj in objects {
//		let o = obj as Task
//		RCLogO(o.date_task_finished)
//		RCLogO(o.notes)
//		}
//		}*/
//		
//		query.cachePolicy = .NetworkElseCache
//		query.getObjectInBackgroundWithId("RNfW4Fgg5y") {
//			(data: PFObject?, error: NSError?) -> Void in
//			
//			if error != nil {
//				RCLogO(error)
//			} else {
//				RCLogO(data?["date_task_finished"])
//				RCLogO(data?["notes"])
//			}
//		}
//	}
	
	func days() -> [Task] {
		
		var currrentDate = NSDate.distantFuture() 
		
		let filteredData = self.tasks.filter { (task: Task) -> Bool in
			
			if let dateEnd = task.endDate {
				if dateEnd.isSameDayAs(currrentDate) == false {
					currrentDate = task.endDate!
					return true
				}
			} else if let dateStart = task.startDate {
				if dateStart.isSameDayAs(currrentDate) == false {
					currrentDate = task.startDate!
					return true
				}
			}
			return false
		}
		
		return filteredData
	}
	
	func tasksForDayOfDate(date: NSDate) -> [Task] {
		
		let filteredData = self.tasks.filter { (task: Task) -> Bool in
			
			if let dateEnd = task.endDate {
				return dateEnd.isSameDayAs(date)
			} else if let dateStart = task.startDate {
				return dateStart.isSameDayAs(date)
			}
			return false
		}
		
		return filteredData
	}
    
    func deleteTask(taskToDelete: Task) {
        
        var indexToRemove = -1
        var canRemove = false
        for theData in self.tasks {
            indexToRemove++
//            if theData === taskToDelete {
//                canRemove = true
////                theData.deleteFromServerWhenPossible()
//                break
//            }
        }
        if canRemove && indexToRemove >= 0 {
            self.tasks.removeAtIndex(indexToRemove)
        }
    }
}

//
//  DataManager.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

let sharedData: DataManagerProtocol = DataManager()

class DataManager: NSObject, DataManagerProtocol {

	private var data = [TaskProtocol]()
	
	func queryData(completion: ([TaskProtocol], NSError?) -> Void) {
		
		let user = PFUser.currentUser()
		let query = PFQuery(className: Task.parseClassName())
		query.cachePolicy = .NetworkElseCache
		query.orderByDescending("date_task_finished")
//		query.whereKey("user", equalTo: user!)
		query.findObjectsInBackgroundWithBlock( { (objects: [AnyObject]?, error: NSError?) in
			if error == nil && objects != nil {
				// TaskProtocol does not conform to AnyObject
				// and as a side note the objc NSArray cannot be directly casted to Swift array
				self.data = [TaskProtocol]()
				for object in objects! {
					self.data.append(object as! Task)
					RCLogO(object)
				}
			}
			completion(self.data, error)
		})
	}
	
	func days() -> [TaskProtocol] {
		
		var currrentDate = NSDate.distantFuture() as! NSDate
		
		let filteredData = self.data.filter { (task: TaskProtocol) -> Bool in
			
			if let dateEnd = task.date_task_finished {
				if dateEnd.isSameDayAs(currrentDate) == false {
					currrentDate = task.date_task_finished!
					return true
				}
			} else if let dateStart = task.date_task_started {
				if dateStart.isSameDayAs(currrentDate) == false {
					currrentDate = task.date_task_started!
					return true
				}
			}
			return false
		}
		
		return filteredData
	}
	
	func tasksForDayOnDate(date: NSDate) -> [TaskProtocol] {
		
		let filteredData = self.data.filter { (task: TaskProtocol) -> Bool in
			
			if let dateEnd = task.date_task_finished {
				return dateEnd.isSameDayAs(date)
			} else if let dateStart = task.date_task_started {
				return dateStart.isSameDayAs(date)
			}
			return false
		}
		
		return filteredData
	}
	
	func addNewTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol {
		
		let task = Task()
		task.date_task_started = dateSart
		task.date_task_finished = dateEnd
		task.task_nr = "AN-0000"
		task.notes = ""
		task.task_type = TaskType.Issue.rawValue
		data.insert(task, atIndex: 0)
		
		return task
	}
	
	func addNewWorkingDayTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol {
		
		let task = addNewTask(dateSart, dateEnd: dateEnd)
		task.task_nr = ""
		task.notes = "Working day started"
		task.task_type = TaskType.Start.rawValue
		
		return task
	}
	
	func addScrumSessionTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol {
		
		let task = addNewTask(dateSart, dateEnd: dateEnd)
		task.task_nr = ""
		task.notes = "Scrum session"
		task.task_type = TaskType.Scrum.rawValue
		
		return task
	}
	
	func addLunchBreakTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol {
		
		let task = addNewTask(dateSart, dateEnd: dateEnd)
		task.task_nr = ""
		task.notes = "Lunch break"
		task.task_type = TaskType.Lunch.rawValue
		
		return task
	}
	
	func addInternalMeetingTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol {
		
		let task = addNewTask(dateSart, dateEnd: dateEnd)
		task.task_nr = "Internal meeting"
		task.notes = ""
		task.task_type = TaskType.Meeting.rawValue
		
		return task
	}
}

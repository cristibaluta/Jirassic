//
//  DataManager.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

let sharedData: DataManagerProtocol = DataManager()

class DataManager: NSObject, DataManagerProtocol {

	private var data = [Task]()
	
	func queryData(completion: ([Task], NSError?) -> Void) {
		
		let user = PFUser.currentUser()
		let query = PFQuery(className: Task.parseClassName())
		query.cachePolicy = .NetworkElseCache
		query.orderByDescending("date_task_finished")
//		query.whereKey("user", equalTo: user!)
		query.findObjectsInBackgroundWithBlock( { (objects: [AnyObject]?, error: NSError?) in
			if (error == nil) {
				self.data = objects as! [Task]
			}
			completion(self.data, error)
		})
	}
	
	func days() -> [Task] {
		
		var currrentDate = NSDate.distantFuture() as! NSDate
		
		let filteredData = self.data.filter { (task: Task) -> Bool in
			
			if task.date_task_finished!.isSameDayAs(currrentDate) == false {
				currrentDate = task.date_task_finished!
				return true
			}
			return false
		}
		
		return filteredData
	}
	
	func tasksForDayOnDate(date: NSDate) -> [Task] {
		
		let filteredData = self.data.filter { (task: Task) -> Bool in
			return task.date_task_finished!.isSameDayAs( date )
		}
		
		return filteredData
	}
	
	func addNewTask(dateSart: NSDate?, dateEnd: NSDate?) -> Task {
		
		let task = Task()
		task.date_task_started = dateSart
		task.date_task_finished = dateEnd
		task.task_nr = "AN-0000"
		task.notes = ""
		task.task_type = TaskType.Issue.rawValue
		data.insert(task, atIndex: 0)
		
		return task
	}
	
	func addNewWorkingDayTask(dateSart: NSDate?, dateEnd: NSDate?) -> Task {
		
		let task = addNewTask(dateSart, dateEnd: dateEnd)
		task.task_nr = ""
		task.notes = "Working day started at \(NSDate().HHmm())"
		task.task_type = TaskType.Start.rawValue
		
		return task
	}
	
	func addScrumSessionTask(dateSart: NSDate?, dateEnd: NSDate?) -> Task {
		
		let task = addNewTask(dateSart, dateEnd: dateEnd)
		task.task_nr = ""
		task.notes = "Scrum session"
		task.task_type = TaskType.Scrum.rawValue
		
		return task
	}
	
	func addLunchBreakTask(dateSart: NSDate?, dateEnd: NSDate?) -> Task {
		
		let task = addNewTask(dateSart, dateEnd: dateEnd)
		task.task_nr = ""
		task.notes = "Lunch break"
		task.task_type = TaskType.Lunch.rawValue
		
		return task
	}
}

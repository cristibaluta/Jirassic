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
		
		let user = JRUser.currentUser()
		RCLogO(user)
		let query = PFQuery(className: Task.parseClassName())
		query.cachePolicy = .NetworkElseCache
		query.orderByDescending(kDateFinishKey)
		query.whereKey("user", equalTo: user!)
		query.findObjectsInBackgroundWithBlock( { (objects: [AnyObject]?, error: NSError?) in
			RCLogO(objects)
			if error == nil && objects != nil {
				// TaskProtocol does not conform to AnyObject
				// and as a side note the objc NSArray cannot be directly casted to Swift array
				self.data = [TaskProtocol]()
				for object in objects! {
					self.data.append(object as! Task)
				}
			}
			completion(self.data, error)
		})
	}
	
	func days() -> [TaskProtocol] {
		
		var currrentDate = NSDate.distantFuture() 
		
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
	
	func tasksForDayOfDate(date: NSDate) -> [TaskProtocol] {
		
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
}

//
//  DataManager.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

let sharedData: DataManagerProtocol = DataManager()

class DataManager: NSObject, DataManagerProtocol {

	private var data = [Task]()
	
	func allData(completion: ([Task], NSError?) -> Void) {
		
		var query = PFQuery(className: Task.parseClassName())
		query.orderByDescending("date_task_finished")
//		query.whereKey("location", nearGeoPoint: PFGeoPoint(location: QRLocationManager.sharedLocation().currentLocation))
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
			
			if task.date_task_finished!.isTheSameDayAs(currrentDate) == false {
				currrentDate = task.date_task_finished!
				return true
			}
			return false
		}
		
		return filteredData
	}
	
	func tasksForDayOnDate(date: NSDate) -> [Task] {
		
		let filteredData = self.data.filter { (task: Task) -> Bool in
			return task.date_task_finished!.isTheSameDayAs( date )
		}
		
		return filteredData
	}
	
	func addTask(task_id: String, notes: String) {
		
		let task = JLTaskWriter().write(task_id, notes: notes)
		data.insert(task, atIndex: 0)
	}
}

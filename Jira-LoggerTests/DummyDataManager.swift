//
//  DummyDataManager.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 29/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class DummyDataManager: NSObject, DataManagerProtocol {
	
	private var data = [Task]()
	
	func queryData(completion: ([Task], NSError?) -> Void) {
		
		let d1 = Task()
		d1.date_task_finished = NSDate()
		d1.task_nr = "AN-3422"
		d1.notes = "Finished the task by deleting the whole project..."
		
		let d1_1 = Task()
		d1_1.date_task_finished = NSDate().dateByAddingTimeInterval(-500100)
		d1_1.task_nr = "AN-3425"
		d1_1.notes = "Finished the task by deleting the whole project..."
		
		let d2 = Task()
		d2.date_task_finished = NSDate().dateByAddingTimeInterval(-500000)
		d2.task_nr = "AN-3423"
		d2.notes = "Finished the task by deleting the whole project..."
		
		let d3 = Task()
		d3.date_task_finished = NSDate().dateByAddingTimeInterval(-369000)
		d3.task_nr = "AN-3423"
		d3.notes = "Finished the task by deleting the whole project. Finished the task by deleting the whole project..."
		
		let d4 = Task()
		d4.date_task_finished = NSDate().dateByAddingTimeInterval(-106500)
		d4.task_nr = "AN-3423"
		d4.notes = "Finished the task by deleting the whole project..."
		
		let d5 = Task()
		d5.date_task_finished = NSDate().dateByAddingTimeInterval(-90600)
		d5.task_nr = "AN-3323"
		d5.notes = "Finished the task by deleting the whole project..."
		
		data = [d1, d1_1, d2, d3, d4, d5]
		
		completion(data, nil)
	}
	
	func days() -> [Task] {
		
		var objects = [Task]()
		var currrentDate = NSDate.distantFuture() as! NSDate
		objects = data.filter { (object: Task) -> Bool in
			RCLogO("> \(object.date_task_finished) isTheSameDayAs \(currrentDate) \(object.date_task_finished!.isTheSameDayAs(currrentDate))")
			if object.date_task_finished!.isTheSameDayAs(currrentDate) == false {
				currrentDate = object.date_task_finished!
				return true
			}
			return false
		}
		
		return objects
	}
	
	func tasksForDayOnDate(date: NSDate) -> [Task] {
		
		var objects = [Task]()
		objects = objects.filter { (object: Task) -> Bool in
			return object.date_task_finished!.isTheSameDayAs( date )
		}
		
		return objects
	}
	
	func addNewTask() -> Task {
		
		let task = Task()
		task.date_task_finished = NSDate()
		task.task_nr = "AN-0000"
		task.notes = "What did you do in this task?"
		
		//		let task = JLTaskWriter().write(task_id, notes: notes)
		data.append(task)
		
		return task
	}
	
	func addTask(task_id: String, notes: String) {
		let task = JLTaskWriter().write(task_id, notes: notes)
		data.append(task)
	}
}

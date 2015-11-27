//
//  MockDataManager.swift
//  Jirassic
//
//  Created by Baluta Cristian on 29/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation
@testable import Jirassic

class MockDataManager: NSObject, DataManagerProtocol {
	
	private var tasks = [Task]()
	
	func queryTasks (completion: ([Task], NSError?) -> Void) {
		
		var d1 = Task()
		d1.endDate = NSDate()
		d1.issueType = "AN-3422"
		d1.notes = "Finished the task by deleting the whole project..."
		
		var d1_1 = Task()
		d1_1.endDate = NSDate().dateByAddingTimeInterval(-500100)
		d1_1.issueType = "AN-3425"
		d1_1.notes = "Finished the task by deleting the whole project..."
		
		var d2 = Task()
		d2.endDate = NSDate().dateByAddingTimeInterval(-500000)
		d2.issueType = "AN-3423"
		d2.notes = "Finished the task by deleting the whole project..."
		
		var d3 = Task()
		d3.endDate = NSDate().dateByAddingTimeInterval(-369000)
		d3.issueType = "AN-3423"
		d3.notes = "Finished the task by deleting the whole project. Finished the task by deleting the whole project..."
		
		var d4 = Task()
		d4.endDate = NSDate().dateByAddingTimeInterval(-106500)
		d4.issueType = "AN-3423"
		d4.notes = "Finished the task by deleting the whole project..."
		
		var d5 = Task()
		d5.endDate = NSDate().dateByAddingTimeInterval(-90600)
		d5.issueType = "AN-3323"
		d5.notes = "Finished the task by deleting the whole project..."
		
		tasks = [d1, d1_1, d2, d3, d4, d5]
		
		completion(tasks, nil)
	}
	
	func allCachedTasks() -> [Task] {
		return tasks
	}
	
	func deleteTask (taskToDelete: Task) {
		
	}
	
	func updateTask (theTask: Task, completion: ((success: Bool) -> Void)) {
		
	}
}

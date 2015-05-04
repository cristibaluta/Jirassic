//
//  DataManagerProtocol.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

@objc protocol DataManagerProtocol: NSObjectProtocol {
	
	func queryData(completion: ([Task], NSError?) -> Void)
	func days() -> [Task]
	func tasksForDayOnDate(date: NSDate) -> [Task]
	func addNewTask() -> Task
//	func updateTask(task_id: String, notes: String)
}

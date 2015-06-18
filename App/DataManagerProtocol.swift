//
//  DataManagerProtocol.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

protocol DataManagerProtocol: NSObjectProtocol {
	
	func queryData(completion: ([TaskProtocol], NSError?) -> Void)
	func days() -> [TaskProtocol]
	func tasksForDayOnDate(date: NSDate) -> [TaskProtocol]
	func addNewTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol
	func addNewWorkingDayTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol
	func addScrumSessionTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol
	func addLunchBreakTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol
	func addInternalMeetingTask(dateSart: NSDate?, dateEnd: NSDate?) -> TaskProtocol
//	func updateTask(task_id: String, notes: String)
}

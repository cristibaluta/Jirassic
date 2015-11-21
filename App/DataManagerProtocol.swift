//
//  DataManagerProtocol.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

protocol DataManagerProtocol: NSObjectProtocol {
	
	func queryTasks(completion: ([Task], NSError?) -> Void)
	func days() -> [Task]
	func tasksForDayOfDate(date: NSDate) -> [Task]
    func deleteTask(dataToDelete: Task)
}

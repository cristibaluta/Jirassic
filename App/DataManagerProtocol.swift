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
	func tasksForDayOfDate(date: NSDate) -> [TaskProtocol]
    func deleteTask(dataToDelete: TaskProtocol)
}

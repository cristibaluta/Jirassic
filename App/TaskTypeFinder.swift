//
//  TaskTypeFinder.swift
//  Jirassic
//
//  Created by Baluta Cristian on 09/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskTypeFinder: NSObject {

	func scrumExists (tasks: [Task]) -> Bool {
		
		var exists = false
		for task in tasks {
			if task.taskType == TaskType.Scrum.rawValue {
				exists = true
				break
			}
		}
		return exists
	}
}

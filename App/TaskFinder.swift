//
//  TaskTypeFinder.swift
//  Jirassic
//
//  Created by Baluta Cristian on 09/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class TaskFinder {

	func scrumExists (_ tasks: [Task]) -> Bool {
		
		var exists = false
		for task in tasks {
			if task.taskType.intValue == TaskType.scrum.rawValue {
				exists = true
				break
			}
		}
        
		return exists
	}
}

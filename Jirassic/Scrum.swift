//
//  Scrum.swift
//  Jirassic
//
//  Created by Baluta Cristian on 09/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class Scrum: NSObject {

	func exists(tasks: [TaskProtocol]) -> Bool {
		var scrumExists = false
		for task in tasks {
			if task.task_type == TaskType.Scrum.rawValue {
				scrumExists = true
				break
			}
		}
		return scrumExists
	}
}

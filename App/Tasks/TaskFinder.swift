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
		
        return tasks.filter({ $0.taskType.intValue == TaskType.scrum.rawValue }).count > 0
	}
    
    func lunchExists (_ tasks: [Task]) -> Bool {
        
        return tasks.filter({ $0.taskType.intValue == TaskType.lunch.rawValue }).count > 0
    }
}

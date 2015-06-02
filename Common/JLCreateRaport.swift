//
//  JLCreateReport.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

let kEightHoursInSeconds: Double = 28800.0

class JLCreateReport: NSObject {

	var tasks = [Task]()
	
	convenience init(tasks: [Task]) {
		
		self.init()
		
		let dateStart = tasks.first!.date_task_finished
		tasks.first!.date_task_finished = tasks.first!.date_task_finished?.roundUp()
		let dateStartAdjusted = tasks.first!.date_task_finished
		let dateEnd = tasks.last?.date_task_finished
		var dateEndAdjusted = dateStartAdjusted!.dateByAddingTimeInterval(kEightHoursInSeconds)
//		var referenceDate = tasks.first?.date_task_finished
		
		let diff = dateEnd?.timeIntervalSinceDate(dateStart!)
		let newDiff = dateEndAdjusted.timeIntervalSinceDate(dateStartAdjusted!)
		
		self.tasks.append(tasks.first!)
		for i in 1...tasks.count-1 {
			let task = tasks[i]
			let prevTask = tasks[i-1]
			
			let duration = task.date_task_finished!.timeIntervalSinceDate(prevTask.date_task_finished!)
			let date = NSDate(timeIntervalSince1970: duration)
			
			// Don't do editings on the lunch break but add it to the end of 8 hrs
			if task.task_type == TaskType.Lunch.rawValue {
				dateEndAdjusted = dateEndAdjusted.dateByAddingTimeInterval(duration)
			}
			else {
				task.date_task_finished = task.date_task_finished?.roundUp()
				
			}
			
			self.tasks.append(task)
		}
	}
}

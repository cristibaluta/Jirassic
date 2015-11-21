//
//  JLCreateReport.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

let kEightHoursInSeconds: Double = 28800.0

class CreateReport: NSObject {

	var tasks = [Task]()
	
	convenience init (tasks: [Task]) {
		self.init()
		
		if tasks.count <= 2 {
			self.tasks = tasks
			return
		}
		
//		let dateStart = tasks.first!.endDate
//		tasks.first!.endDate = tasks.first!.endDate?.roundUp()
		let dateStartAdjusted = tasks.first!.endDate
//		let dateEnd = tasks.last?.date_task_finished
		var dateEndAdjusted = dateStartAdjusted!.dateByAddingTimeInterval(kEightHoursInSeconds)
		
//		let diff = dateEnd?.timeIntervalSinceDate(dateStart!)
//		let newDiff = dateEndAdjusted.timeIntervalSinceDate(dateStartAdjusted!)
		
		self.tasks.append(tasks.first!)
		
		if tasks.count > 2 {
			for i in 1...tasks.count-2 {
				var task = tasks[i]
				let prevTask = tasks[i-1]
				
				task.endDate = task.endDate?.roundUp()
				
				if task.taskType == TaskType.Lunch.rawValue {
					let duration = task.endDate!.timeIntervalSinceDate(prevTask.endDate!)
					RCLogO(duration)
					dateEndAdjusted = dateEndAdjusted.dateByAddingTimeInterval(duration)
				}
				self.tasks.append(task)
			}
		}
		
//		tasks.last?.endDate = dateEndAdjusted
		self.tasks.append(tasks.last!)
	}
	
	private func lunchTimeInterval (tasks: [Task]) -> NSTimeInterval {
		
		var referenceDate = tasks.first?.endDate
		for task in tasks {
			if task.taskType == TaskType.Lunch.rawValue {
				return task.endDate!.timeIntervalSinceDate(referenceDate!)
			}
			referenceDate = task.endDate
		}
		return 0.0
	}
}

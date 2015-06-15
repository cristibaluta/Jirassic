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
	
	convenience init(tasks: [Task]) {
		
		self.init()
		
		if tasks.count <= 2 {
			self.tasks = tasks
			return
		}
		
		let dateStart = tasks.first!.date_task_finished
		tasks.first!.date_task_finished = tasks.first!.date_task_finished?.roundUp()
		let dateStartAdjusted = tasks.first!.date_task_finished
		let dateEnd = tasks.last?.date_task_finished
		var dateEndAdjusted = dateStartAdjusted!.dateByAddingTimeInterval(kEightHoursInSeconds)
		
//		let diff = dateEnd?.timeIntervalSinceDate(dateStart!)
//		let newDiff = dateEndAdjusted.timeIntervalSinceDate(dateStartAdjusted!)
		
		self.tasks.append(tasks.first!)
		
		if tasks.count > 2 {
			for i in 1...tasks.count-2 {
				let task = tasks[i]
				let prevTask = tasks[i-1]
				
				task.date_task_finished = task.date_task_finished?.roundUp()
				
				if task.task_type == TaskType.Lunch.rawValue {
					let duration = task.date_task_finished!.timeIntervalSinceDate(prevTask.date_task_finished!)
					RCLogO(duration)
					dateEndAdjusted = dateEndAdjusted.dateByAddingTimeInterval(duration)
				}
				self.tasks.append(task)
			}
		}
		
		tasks.last?.date_task_finished = dateEndAdjusted
		self.tasks.append(tasks.last!)
	}
	
	private func lunchTimeInterval(tasks: [Task]) -> NSTimeInterval {
		var referenceDate = tasks.first?.date_task_finished
		for task in tasks {
			if task.task_type == TaskType.Lunch.rawValue {
				return task.date_task_finished!.timeIntervalSinceDate(referenceDate!)
			}
			referenceDate = task.date_task_finished
		}
		return 0.0
	}
}

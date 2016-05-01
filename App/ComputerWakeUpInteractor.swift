//
//  ComputerWakeUpInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ComputerWakeUpInteractor: NSObject {

	var data: Repository!
	
	convenience init (data: Repository) {
		self.init()
		self.data = data
	}
	
	func runWithLastSleepDate (date: NSDate?) {
		
		let reader = ReadDayInteractor(data: data)
		let existingTasks = reader.tasksForDayOfDate(NSDate())
		if existingTasks.count > 0 {
			// We already started the day, analyze if it's scrum time
			if TaskTypeFinder().scrumExists(existingTasks) {
				let task = Task(dateSart: date, dateEnd: NSDate(), type: TaskType.Scrum)
				localRepository.updateTask(task, completion: {(success: Bool) -> Void in })
				InternalNotifications.taskAdded(task)
			}
		} else {
			// This might be the start of the day. Should we start counting automatically or wait the user to press start?
			
		}
	}
}

//
//  ComputerSleepInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class ComputerSleepInteractor: NSObject {

	var data: Repository!
	
	convenience init (data: Repository) {
		self.init()
		self.data = data
	}
	
	func run() {
		let reader = ReadDayInteractor(data: data)
		let existingTasks = reader.tasksForDayOfDate(NSDate())
		if existingTasks.count > 0 {
			// We already started the day, analyze if it's scrum time
			
		}
	}
}

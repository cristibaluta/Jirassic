//
//  ReadDayInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadDayInteractor: NSObject {
	
	var data: DataManagerProtocol!
	
	convenience init (data: DataManagerProtocol) {
		self.init()
		self.data = data
	}
	
	func tasksForDayOfDate (date: NSDate) -> [Task] {
		
		let filteredData = data.allCachedTasks().filter { (task: Task) -> Bool in
			
			if let dateEnd = task.endDate {
				return dateEnd.isSameDayAs(date)
			} else if let dateStart = task.startDate {
				return dateStart.isSameDayAs(date)
			}
			return false
		}
		
		return filteredData
	}
}

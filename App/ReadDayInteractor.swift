//
//  ReadDayInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadDayInteractor {
	
	var data: Repository!
	
	convenience init (data: Repository) {
		self.init()
		self.data = data
	}
	
	func tasksInDay (date: NSDate) -> [Task] {
		
        let filteredData = data.queryTasksInDay(date)
//        { (tasks: [Task]) in
        
//        }
//        allCachedTasks().filter { (task: Task) -> Bool in
//			
//			if let dateEnd = task.endDate {
//				return dateEnd.isSameDayAs(date)
//			} else if let dateStart = task.startDate {
//				return dateStart.isSameDayAs(date)
//			}
//			return false
//		}
		
		return filteredData
	}
}

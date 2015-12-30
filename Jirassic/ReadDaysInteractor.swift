//
//  ReadDaysInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadDaysInteractor: NSObject {
	
	var data: DataManagerProtocol!
	
	convenience init (data: DataManagerProtocol) {
		self.init()
		self.data = data
	}
	
	func weeks() -> [Week] {
		
		var objects = [Week]()
		var referenceDate = NSDate.distantFuture()
		let filteredTasks = data.allCachedTasks().filter { (task: Task) -> Bool in
			
			if let dateToCompare = task.endDate ?? task.startDate {
				if dateToCompare.isSameWeekAs(referenceDate) == false {
					referenceDate = dateToCompare
					return true
				}
			}
			return false
		}
		
		for task in filteredTasks {
			if let dateToCompare = task.endDate ?? task.startDate {
				let obj = Week(date: dateToCompare)
				obj.days = days(obj)
				objects.append(obj)
			}
		}
		
		return objects
	}
	
	func days (week: Week) -> [Day] {
		
		var objects = [Day]()
		var referenceDate = NSDate.distantFuture()
		let filteredTasks = data.allCachedTasks().filter { (task: Task) -> Bool in
			
			if let dateToCompare = task.endDate ?? task.startDate {
				if (dateToCompare.isSameWeekAs(week.date)) {
					if dateToCompare.isSameDayAs(referenceDate) == false {
						referenceDate = dateToCompare
						return true
					}
				}
			}
			return false
		}
		for task in filteredTasks {
			if let dateToCompare = task.endDate ?? task.startDate {
				let obj = Day(date: dateToCompare)
				objects.append(obj)
			}
		}
		
		return objects
	}
}

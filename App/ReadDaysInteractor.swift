//
//  ReadDaysInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadDaysInteractor: RepositoryInteractor {
	
	private var tasks = [Task]()
	
    convenience init (data: Repository) {
        self.init()
        
        self.data = data
		self.tasks = data.queryUnsyncedTasks()
		self.tasks.sortInPlace { (task1: Task, task2: Task) -> Bool in
			if let date1 = task1.endDate ?? task1.startDate {
				if let date2 = task2.endDate ?? task2.startDate {
					return date1.compare(date2) == .OrderedDescending
				}
			}
			return false
		}
	}
	
	func weeks() -> [Week] {
		
		var objects = [Week]()
		var referenceDate = NSDate.distantFuture()
		
		for task in tasks {
			if let dateToCompare = task.endDate ?? task.startDate {
				if !dateToCompare.isSameWeekAs(referenceDate) {
					referenceDate = dateToCompare
					let obj = Week(date: dateToCompare)
					obj.days = days(obj)
					objects.append(obj)
				}
			}
		}
		
		return objects
	}
	
	func days() -> [Day] {
		
		var objects = [Day]()
		var referenceDate = NSDate.distantFuture()
		
		for task in tasks {
			if let dateToCompare = task.endDate ?? task.startDate {
				if !dateToCompare.isSameDayAs(referenceDate) {
					referenceDate = dateToCompare
					let obj = Day(date: dateToCompare)
					objects.append(obj)
				}
			}
		}
		
		return objects
	}
	
	private func days (week: Week) -> [Day] {
		
		var objects = [Day]()
		var referenceDate = NSDate.distantFuture()
		
		for task in tasks {
			if let dateToCompare = task.endDate ?? task.startDate {
				if (dateToCompare.isSameWeekAs(week.date)) {
					if !dateToCompare.isSameDayAs(referenceDate) {
						referenceDate = dateToCompare
						let obj = Day(date: dateToCompare)
						objects.append(obj)
					}
				}
			}
		}
		
		return objects
	}
}

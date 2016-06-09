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
		data.queryTasks(0, completion: { (tasks, error) in
            
            self.tasks = tasks
            self.tasks.sortInPlace { (task1: Task, task2: Task) -> Bool in
                return task1.endDate.compare(task2.endDate) == .OrderedDescending
            }
        })
	}
	
	func weeks() -> [Week] {
		
		var objects = [Week]()
		var referenceDate = NSDate.distantFuture()
		
		for task in tasks {
            if !task.endDate.isSameWeekAs(referenceDate) {
                referenceDate = task.endDate
                let obj = Week(date: task.endDate)
                obj.days = days(obj)
                objects.append(obj)
            }
		}
		
		return objects
	}
	
	func days() -> [Day] {
		
		var objects = [Day]()
		var referenceDate = NSDate.distantFuture()
		
		for task in tasks {
            if !task.endDate.isSameDayAs(referenceDate) {
                referenceDate = task.endDate
                let obj = Day(date: task.endDate)
                objects.append(obj)
            }
		}
		
		return objects
	}
	
	private func days (week: Week) -> [Day] {
		
		var objects = [Day]()
		var referenceDate = NSDate.distantFuture()
		
		for task in tasks {
            if (task.endDate.isSameWeekAs(week.date)) {
                if !task.endDate.isSameDayAs(referenceDate) {
                    referenceDate = task.endDate
                    let obj = Day(date: task.endDate)
                    objects.append(obj)
                }
            }
		}
		
		return objects
	}
}

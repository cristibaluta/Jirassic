//
//  ReadDaysInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadDaysInteractor: RepositoryInteractor {
	
	fileprivate var tasks = [Task]()
	
    override init (repository: Repository) {
        super.init(repository: repository)
	}
    
    /*
     Query the objects from the repository before getting the weeks and days
     */
    func query (_ completion: @escaping (_ weeks: [Week]) -> Void) {
        
        repository.queryTasks(0, completion: { (tasks, error) in
            
            self.tasks = tasks
            self.tasks.sort { (task1: Task, task2: Task) -> Bool in
                return task1.endDate.compare(task2.endDate) == .orderedDescending
            }
            
            completion(self.weeks())
            
            if let remoteRepository = remoteRepository {
                let sync = RCSync<Task>(localRepository: self.repository, remoteRepository: remoteRepository)
                sync.start { hasIncomingChanges in
                    
                    if hasIncomingChanges {
                        self.repository.queryTasks(0, completion: { (tasks, error) in
                            
                            self.tasks = tasks
                            self.tasks.sort { (task1: Task, task2: Task) -> Bool in
                                return task1.endDate.compare(task2.endDate) == .orderedDescending
                            }
                            
                            completion(self.weeks())
                        })
                    }
                }
            }
        })
    }
	
	func weeks() -> [Week] {
		
		var objects = [Week]()
		var referenceDate = Date.distantFuture
		
		for task in tasks {
            if !task.endDate.isSameWeekAs(referenceDate) {
                referenceDate = task.endDate
                let obj = Week(date: task.endDate)
                obj.days = days(ofWeek: obj)
                objects.append(obj)
            }
		}
		
		return objects
	}
	
	func days() -> [Day] {
		
		var objects = [Day]()
		var referenceDate = Date.distantFuture
		
		for task in tasks {
            if !task.endDate.isSameDayAs(referenceDate) {
                referenceDate = task.endDate
                let obj = Day(date: task.endDate)
                objects.append(obj)
            }
		}
		
		return objects
	}
	
	fileprivate func days (ofWeek week: Week) -> [Day] {
		
		var objects = [Day]()
		var referenceDate = Date.distantFuture
		
		for task in tasks {
            if task.endDate.isSameWeekAs(week.date) {
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

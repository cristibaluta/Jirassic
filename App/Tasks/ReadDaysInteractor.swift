//
//  ReadDaysInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

// Interactor responsible for querying and building Days snd Weeks.
// Only start and end tasks will be queried for performance reasons
class ReadDaysInteractor: RepositoryInteractor {
	
	private var tasks = [Task]()
	
    /// Query all startDay and endDay objects from the local repository
    /// Then do a sync with the remote if enabled and query the local objects again
    /// @parameters
    /// completion block will be called once with local tasks and once with updated tasks if remote had any changes to download
    func queryAll (_ completion: @escaping (_ weeks: [Week]) -> Void) {
        query(startingDate: Date(timeIntervalSince1970: 0), completion: completion)
    }

    /// Query all startDay and endDay objects from the local repository
    /// Then do a sync with the remote if enabled and query the local objects again
    /// @parameters
    /// startingDate - Query between this date and current date
    /// completion block - will be called once with local tasks and once with updated tasks if remote had any changes to download
    func query (startingDate: Date, completion: @escaping (_ weeks: [Week]) -> Void) {

        queryLocalTasks(startDate: startingDate, endDate: Date()) { [weak self] (tasks: [Task]) in
            
            guard let _self = self else {
                return
            }
            _self.tasks = tasks
            completion(_self.weeks())
            
            if let remoteRepository = _self.remoteRepository {
                
                let sync = RCSync<Task>(localRepository: _self.repository, remoteRepository: remoteRepository)
                sync.start { [weak self] hasIncomingChanges in
                    
                    guard let _self = self, hasIncomingChanges else {
                        return
                    }
                    // Fetch again the local tasks if they were updated
                    _self.queryLocalTasks(startDate: startingDate, endDate: Date()) { (tasks: [Task]) in
                        _self.tasks = tasks
                        completion(_self.weeks())
                    }
                }
            }
        }
    }

    private func queryLocalTasks (startDate: Date, endDate: Date, _ completion: @escaping (_ tasks: [Task]) -> Void) {
        
        let predicateWithStartAndEndDays = NSPredicate(format: "taskType == %i || taskType == %i", TaskType.startDay.rawValue, TaskType.endDay.rawValue)
        
        repository.queryTasks(startDate: startDate, endDate: endDate, predicate: predicateWithStartAndEndDays, completion: { [weak self] (tasks, error) in
            
            guard let _self = self else {
                return
            }
            let tasks = _self.sorted(tasks: tasks)
            completion(tasks)
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
        var obj: Day?
		var referenceDate = Date.distantFuture
		
		for task in tasks {
            if task.endDate.isSameDayAs(referenceDate) {
                if task.taskType == .endDay {
                    let tempObj = objects.removeLast()
                    obj = Day(dateStart: tempObj.dateStart, dateEnd: task.endDate)
                    objects.append(obj!)
                }
            } else {
                referenceDate = task.endDate
                obj = Day(dateStart: task.endDate, dateEnd: nil)
                objects.append(obj!)
            }
		}
		
		return objects
	}
	
    private func sorted (tasks: [Task]) -> [Task] {
        return tasks.sorted { (task1: Task, task2: Task) -> Bool in
            return task1.endDate.compare(task2.endDate) == .orderedDescending
        }
    }
    
	private func days (ofWeek week: Week) -> [Day] {
		
		var objects = [Day]()
        var activeDay: Day?
		var referenceDate = Date.distantFuture
		
        // Tasks are sorted descending
		for task in tasks {
            if task.endDate.isSameWeekAs(week.date) {
                if task.endDate.isSameDayAs(referenceDate) {
                    // Check if we reached the begining of the day and recreate the object with the real startDate
                    if task.taskType == .startDay {
                        if objects.count > 0 {
                            let tempDay = objects.removeLast()
                            activeDay = Day(dateStart: task.endDate, dateEnd: tempDay.dateEnd)
                        } else {
                            activeDay = Day(dateStart: task.endDate, dateEnd: nil)
                        }
                        objects.append(activeDay!)
                    }
                } else {
                    var endDate: Date?
                    if task.taskType == .endDay {
                        endDate = task.endDate
                    }
                    referenceDate = task.endDate
                    activeDay = Day(dateStart: task.endDate, dateEnd: endDate)
                    objects.append(activeDay!)
                }
            }
		}
		
		return objects
	}
}

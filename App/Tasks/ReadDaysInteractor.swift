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
        query(startingDate: Date(timeIntervalSince1970: 0), endingDate: Date(), completion: completion)
    }

    /// Query all startDay and endDay objects from the local repository
    /// Then do a sync with the remote if enabled and query the local objects again
    /// @parameters
    /// startingDate - Query between this date and current date
    /// completion block - will be called once with local tasks and once with updated tasks if remote had any changes to download
    func query (startingDate: Date, endingDate: Date, completion: @escaping (_ weeks: [Week]) -> Void) {

        queryLocalTasks(startDate: startingDate, endDate: endingDate) { [weak self] (tasks: [Task]) in
            
            guard let self = self else {
                return
            }
            self.tasks = tasks
            completion(self.createWeeks())
            
            guard let remoteRepository = self.remoteRepository else {
                return
            }
                
            let sync = RCSync<Task>(localRepository: self.repository, remoteRepository: remoteRepository)
            sync.start { [weak self] hasIncomingChanges in
                
                guard let self = self, hasIncomingChanges else {
                    return
                }
                // Delete dusplicate start day
                RemoveDuplicate(repository: self.repository, remoteRepository: self.remoteRepository, date: Date()).execute()
                // Fetch again the local tasks if they were updated
                self.queryLocalTasks(startDate: startingDate, endDate: Date()) { (tasks: [Task]) in
                    self.tasks = tasks
                    completion(self.createWeeks())
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
	
	private func createWeeks() -> [Week] {
		
		var weeks = [Week]()
		var referenceDate = Date.distantFuture
		
		for task in tasks {
            if !task.endDate.isSameWeekAs(referenceDate) {
                referenceDate = task.endDate
                let week = Week(date: task.endDate)
                week.days = createDaysFromAscendingTasks(ofWeek: week)
                weeks.append(week)
            }
		}
		
		return weeks
	}
	
//	private func createDays() -> [Day] {
//
//		var objects = [Day]()
//        var obj: Day?
//		var referenceDate = Date.distantFuture
//
//		for task in tasks {
//            if task.endDate.isSameDayAs(referenceDate) {
//                if task.taskType == .endDay {
//                    let tempObj = objects.removeLast()
//                    obj = Day(dateStart: tempObj.dateStart, dateEnd: task.endDate)
//                    objects.append(obj!)
//                }
//            } else {
//                referenceDate = task.endDate
//                obj = Day(dateStart: task.endDate, dateEnd: nil)
//                objects.append(obj!)
//            }
//		}
//
//		return objects
//	}
	
    private func createDaysFromAscendingTasks (ofWeek week: Week) -> [Day] {
        
        var days = [Day]()
        var activeDay: Day?
        var referenceDate = Date.distantFuture
        
        for task in tasks {
            guard task.endDate.isSameWeekAs(week.date) else {
                continue
            }
            switch task.taskType {
                case .startDay:
                    // New day found
                    referenceDate = task.endDate
                    activeDay = Day(dateStart: referenceDate, dateEnd: nil)
                    days.append(activeDay!)
                case .endDay:
                    // End of day found.
                    guard task.endDate.isSameDayAs(referenceDate) else {
                        continue
                    }
                    let tempDay = days.removeLast()
                    activeDay = Day(dateStart: tempDay.dateStart, dateEnd: task.endDate)
                    days.append(activeDay!)
                default: break
            }
        }
        
        return days
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
    
    private func sorted (tasks: [Task]) -> [Task] {
        return tasks.sorted { (task1: Task, task2: Task) -> Bool in
            return task1.endDate.compare(task2.endDate) == .orderedAscending
        }
    }
}

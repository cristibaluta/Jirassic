//
//  CreateReport.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class CreateReport: NSObject {

    fileprivate let targetHoursInDay = 8.0.hoursToSec
	fileprivate var tasks = [Task]()
	
	convenience init (tasks: [Task]) {
		self.init()
		self.tasks = tasks
	}
	
	func reports() -> [Report] {
		
		guard tasks.count > 1 else {
			return []
        }
        for t in tasks {
            RCLog(t.endDate)
        }
        tasks = splitOverlappingTasks(tasks)
        for t in tasks {
            RCLog(t.endDate)
        }
        return []
        
		// Calculate the diff to 8 hrs
		let totalTime = tasks.last!.endDate.timeIntervalSince(tasks.first!.endDate)
		let lunchDuration = self.lunchDuration
		let workedTime = totalTime - lunchDuration
		let missingTime = targetHoursInDay - workedTime
		let extraTimePerTask = ceil( Double( Int(missingTime) / tasks.count))
        
        addExtraTimeToTasks(extraTimePerTask: extraTimePerTask)

        let groups = groupsByTaskNumber()
        let reports = reportsFromGroups(groups)
        
        return reports
	}
}

extension CreateReport {
    
    fileprivate func splitOverlappingTasks (_ tasks: [Task]) -> [Task] {
        
        var expandedTasks = [Task]()
        var inlinedTasks = [Task]()
        var task = tasks.first!
        var previousDate = task.endDate
        var inlineDuration: TimeInterval = 0.0
        
        for i in 1..<tasks.count {
            
            task = tasks[i]
            
            if let startDate = task.startDate {
                // Task with begining and ending defined
                inlinedTasks.append(task)
                inlineDuration += task.endDate.timeIntervalSince(startDate)
            } else {
                inlineDuration = 0.0
                // Add the task but substract the time from the inlined tasks
                task.endDate = task.endDate.addingTimeInterval(-inlineDuration)
                expandedTasks.append(task)
                previousDate = task.endDate
                
                // Add the inlined tasks
                for itask in inlinedTasks {
                    var tempTask = itask
                    let duration = tempTask.endDate.timeIntervalSince(tempTask.startDate!)
                    tempTask.startDate = nil
                    tempTask.endDate = previousDate.addingTimeInterval(duration)
                    expandedTasks.append(task)
                    previousDate = tempTask.endDate
                }
                inlinedTasks = []
            }
        }
        return expandedTasks
    }
    
    fileprivate func addExtraTimeToTasks (extraTimePerTask: Double) {
        
        var extraTimeToAdd = extraTimePerTask
        
        var task = tasks.first!
        task.endDate = task.endDate.round()
        tasks[0] = task
        var previousDate = task.endDate
        var lunchDuration = 0.0
        
        for i in 1..<tasks.count - 1 {
            
            task = tasks[i]
            
            if task.taskType.intValue == TaskType.lunch.rawValue {
                lunchDuration = task.endDate.timeIntervalSince(previousDate)
            } else {
                if let startDate = task.startDate {
                    // For tasks with start and end date
                    task.endDate = task.endDate.addingTimeInterval(extraTimeToAdd - lunchDuration).round()
                    task.startDate = startDate.addingTimeInterval(extraTimeToAdd - lunchDuration).round()
                    extraTimeToAdd += extraTimePerTask
                } else {
                    // For tasks with only end date
                    task.endDate = task.endDate.addingTimeInterval(extraTimeToAdd - lunchDuration).round()
                    task.startDate = previousDate
                    extraTimeToAdd += extraTimePerTask
                }
                tasks[i] = task
            }
            previousDate = task.endDate
            RCLog("\(task.startDate) - \(task.endDate)")
        }
        
        // Handle the last task separately, add the remaining time till targetHoursInDay
        task = tasks.last!
        task.endDate = tasks.first!.endDate.addingTimeInterval(targetHoursInDay + lunchDuration)
        task.startDate = previousDate
        tasks[tasks.count-1] = task
    }
    
    fileprivate func groupsByTaskNumber() -> [String: [Task]] {
        
        var groups = [String: [Task]]()
        for task in tasks {
            if task.taskType.intValue == TaskType.startDay.rawValue {
                continue
            }
            let taskNumber = task.taskNumber ?? String.random()
            var tgroup: [Task]? = groups[taskNumber]
            if tgroup == nil {
                tgroup = [Task]()
                groups[taskNumber] = tgroup
            }
            tgroup?.append(task)
            groups[taskNumber] = tgroup!
        }
        
        return groups
    }
    
    fileprivate func reportsFromGroups (_ groups: [String: [Task]]) -> [Report] {
        
        var reportsMap = [String: Report]()
        
        for (taskNumber, tasks) in groups {
            
            for task in tasks {
                
                guard task.taskType.intValue != TaskType.lunch.rawValue else {
                    continue
                }
                
                var report = reportsMap[taskNumber]
                
                if report == nil {
                    report = Report(duration: task.endDate.timeIntervalSince(task.startDate!),
                                    notes: "• \(task.notes ?? "")",
                                    taskNumber: taskNumber)
                } else {
                    report!.duration += task.endDate.timeIntervalSince(task.startDate!)
                    report!.notes = "\(report!.notes)\n• \(task.notes!)"
                }
                reportsMap[taskNumber] = report
            }
        }
        
        return Array(reportsMap.values)
	}
	
	fileprivate var lunchDuration: TimeInterval {
		
		var lastTaskEndDate = tasks.first?.endDate
		for task in tasks {
			if task.taskType.intValue == TaskType.lunch.rawValue {
				return task.endDate.timeIntervalSince(lastTaskEndDate! as Date)
			}
			lastTaskEndDate = task.endDate
		}
		return 0.0
	}
}

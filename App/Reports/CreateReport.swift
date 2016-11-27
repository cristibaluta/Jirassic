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
	
	func reports (fromTasks tasks: [Task]) -> [Report] {
		
		guard tasks.count > 1 else {
			return []
        }
        var tasks = splitOverlappingTasks(tasks)
        tasks = removeFood(tasks)
        
		// Calculate the diff to 8 hrs
		let workedTime = tasks.last!.endDate.timeIntervalSince(tasks.first!.endDate)
		let missingTime = targetHoursInDay - workedTime
		let extraTimePerTask = ceil( Double( Int(missingTime) / tasks.count))
        
        tasks = addExtraTimeToTasks(tasks, extraTimePerTask: extraTimePerTask)
        
        let groups = groupByTaskNumber(tasks)
        let reports = reportsFromGroups(groups)
        
        return reports
	}
}

extension CreateReport {
    
    fileprivate func splitOverlappingTasks (_ tasks: [Task]) -> [Task] {
        
        var arr = [Task]()
        var task = tasks.first!
        var previousDate = task.endDate
        arr.append(task)
        
        for i in 1..<tasks.count {
            
            task = tasks[i]
            
            if let startDate = task.startDate {
                // Task with begining and ending defined
                let duration = task.endDate.timeIntervalSince(startDate)
                task.startDate = nil
                task.endDate = previousDate.addingTimeInterval(duration)
                arr.append(task)
                previousDate = task.endDate
                print("inlined \(startDate)")
            } else {
                // Add the task but substract the time from the inlined tasks
                arr.append(task)
                previousDate = task.endDate
            }
        }
        return arr
    }
    
    fileprivate func removeFood (_ tasks: [Task]) -> [Task] {
        
        var arr = [Task]()
        var lunchDuration = 0.0
        var lastTaskEndDate = tasks.first!.endDate
        
        for task in tasks {
            
            guard task.taskType != TaskType.lunch else {
                lunchDuration += task.endDate.timeIntervalSince(lastTaskEndDate)
                continue
            }
            var tempTask = task
            tempTask.endDate = task.endDate.addingTimeInterval(-lunchDuration)
            arr.append(tempTask)
            lastTaskEndDate = tempTask.endDate
        }
        return arr
    }
    
    fileprivate func addExtraTimeToTasks (_ tasks: [Task], extraTimePerTask: Double) -> [Task] {
        
        var roundedTasks = [Task]()
        var extraTimeToAdd = extraTimePerTask
        
        var task = tasks.first!
        task.endDate = task.endDate.round()
        roundedTasks.append(task)
        var previousDate = task.endDate
        
        for i in 1..<tasks.count - 1 {
            
            task = tasks[i]
            
            task.endDate = task.endDate.addingTimeInterval(extraTimeToAdd).round()
            task.startDate = previousDate
            extraTimeToAdd += extraTimePerTask
            previousDate = task.endDate
            
            roundedTasks.append(task)
        }
        
        // Handle the last task separately, add the remaining time till targetHoursInDay
        task = tasks.last!
        task.endDate = roundedTasks.first!.endDate.addingTimeInterval(targetHoursInDay)
        task.startDate = previousDate
        roundedTasks.append(task)
        
        return roundedTasks
    }
    
    fileprivate func groupByTaskNumber (_ tasks: [Task]) -> [String: [Task]] {
        
        var groups = [String: [Task]]()
        for task in tasks {
            if task.taskType == TaskType.startDay {
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
                
                guard task.taskType != TaskType.lunch else {
                    continue
                }
                guard let startDate = task.startDate else {
                    continue
                }
                
                var report = reportsMap[taskNumber]
                
                if report == nil {
                    report = Report(duration: task.endDate.timeIntervalSince(startDate),
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
}

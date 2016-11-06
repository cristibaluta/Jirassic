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
        print(tasks)
		
		// Calculate the diff to 8 hrs
		let totalTime = tasks.last!.endDate.timeIntervalSince(tasks.first!.endDate)
		let lunchDuration = self.lunchDuration
		let workedTime = totalTime - lunchDuration
		let missingTime = targetHoursInDay - workedTime
		let extraTimePerTask = ceil(Double(Int(missingTime) / (tasks.count)))
        
        addExtraTimeToTasks (extraTimePerTask: extraTimePerTask, lunchDuration: lunchDuration)

        let groups = groupsByTaskNumber()
        let reports = reportsFromGroups(groups: groups)
        print(groups)
        print(reports)
        
        return reports
	}
}

extension CreateReport {

    fileprivate func addExtraTimeToTasks (extraTimePerTask: Double, lunchDuration: Double) {
        
        var extraTimeToAdd = extraTimePerTask
        
        for i in 0..<tasks.count - 1 {
            var task = tasks[i]
            if i > 0 {
                task.endDate = task.endDate.addingTimeInterval(extraTimeToAdd)
            }
            task.endDate = task.endDate.round()
            extraTimeToAdd += extraTimePerTask
            tasks[i] = task
        }
        
        // Handle the last task separately, add the remaining time to targetHoursInDay
        var task = tasks.last!
        task.endDate = tasks.first!.endDate.addingTimeInterval(targetHoursInDay + lunchDuration)
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
    
    fileprivate func reportsFromGroups (groups: [String: [Task]]) -> [Report] {
        
        var reportsMap = [String: Report]()
        
        for (taskNumber, tasks) in groups {
            
            var previousTask: Task?
            
            for task in tasks {
                
                var report = reportsMap[taskNumber]
                
                if report == nil {
                    previousTask = task
                    report = Report(duration: 0.0,
                                    notes: "• \(task.notes!)",
                                    taskNumber: taskNumber)
                }
                else {
                    report!.duration += task.endDate.timeIntervalSince(previousTask!.endDate)
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

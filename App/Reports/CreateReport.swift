//
//  CreateReport.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class CreateReport: NSObject {
    
    func reports (fromTasks tasks: [Task], targetHoursInDay: Double) -> [Report] {
		
		guard tasks.count > 1 else {
			return []
        }
        var tasks = splitOverlappingTasks(tasks)
        tasks = removeUntrackableTasks(tasks)
        tasks = addExtraTimeToTasks(tasks, targetHoursInDay: targetHoursInDay)
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
//                print("inlined \(startDate)")
            } else {
                // Add the task but substract the time from the inlined tasks
                arr.append(task)
                previousDate = task.endDate
            }
        }
        return arr
    }
    
    fileprivate func removeUntrackableTasks (_ tasks: [Task]) -> [Task] {
        
        var arr = [Task]()
        var untrackedDuration = 0.0
        var lastTaskEndDate = tasks.first!.endDate
        
        for task in tasks {
            
            guard isTrackable(taskType: task.taskType) else {
                untrackedDuration += task.endDate.timeIntervalSince(lastTaskEndDate)
                continue
            }
            var tempTask = task
            tempTask.endDate = task.endDate.addingTimeInterval(-untrackedDuration)
            arr.append(tempTask)
            lastTaskEndDate = tempTask.endDate
        }
        return arr
    }
    
    fileprivate func isTrackable (taskType: TaskType) -> Bool {
        switch taskType {
        case .lunch, .nap: return false
        default: return true
        }
    }
    
    fileprivate func isAdjustable (taskType: TaskType) -> Bool {
        switch taskType {
        case .scrum, .meeting, .learning: return false
        default: return true
        }
    }
    
    fileprivate func addExtraTimeToTasks (_ tasks: [Task], targetHoursInDay: Double) -> [Task] {
        
        // How many tasks should be adjusted
        let tasksToAdjust = tasks.filter({ isAdjustable(taskType: $0.taskType) }).count
        
        // Calculate the diff to targetHoursInDay
        let workedTime = tasks.last!.endDate.timeIntervalSince(tasks.first!.endDate)
        let missingTime = targetHoursInDay - workedTime
        let extraTimePerTask = ceil( Double( Int(missingTime) / tasksToAdjust))
        
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
            previousDate = task.endDate
            if tasks.count > i + 1 {
                let nextTask = tasks[i+1]
                if isAdjustable(taskType: nextTask.taskType) {
                    extraTimeToAdd += extraTimePerTask
                }
            }
            
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
            let taskNumber = task.taskNumber ?? ""
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
                
                guard isTrackable(taskType: task.taskType) else {
                    continue
                }
                guard let startDate = task.startDate else {
                    // This shouldn't happen. It can happen only if there's no start of the day
                    continue
                }
                
                var report = reportsMap[taskNumber]
                
                if report == nil {
                    report = Report(duration: task.endDate.timeIntervalSince(startDate),
                                    notes: "• \(task.notes ?? "")",
                                    taskNumber: taskNumber)
                } else {
                    report!.duration += task.endDate.timeIntervalSince(task.startDate!)
                    report!.notes = "\(report!.notes)\n• \(task.notes ?? "")"
                }
                reportsMap[taskNumber] = report
            }
        }
        
        return Array(reportsMap.values)
	}
}

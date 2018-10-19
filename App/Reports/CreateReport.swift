//
//  CreateReport.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class CreateReport {
    
    func reports (fromTasks tasks: [Task], targetHoursInDay: Double?) -> [Report] {
		
        // .endDay task is not part of reports
        let filteredTasks = tasks.filter({ $0.taskType != .endDay })
		guard filteredTasks.count > 1 else {
			return []
        }
        var processedTasks = splitOverlappingTasks(filteredTasks)
        processedTasks = removeUntrackableTasks(processedTasks)
        processedTasks = addExtraTimeToTasks(processedTasks, targetHoursInDay: targetHoursInDay)
        let groups = groupByTaskNumber(processedTasks)
        let reports = reportsFromGroups(groups.groups)
        
        return sortReports(reports, withOrder: groups.order)
	}
}

extension CreateReport {
    
    private func splitOverlappingTasks (_ tasks: [Task]) -> [Task] {
        
        var arr = [Task]()
        var task = tasks.first!
        var previousEndDate = task.endDate
        arr.append(task)
        
        for i in 1..<tasks.count {
            
            task = tasks[i]
            
            if let startDate = task.startDate {
                // Tasks with begining and ending defined are inlined tasks.
                // Extract them in front of the overlapped task. This will take from the time of the actual task
                let duration = task.endDate.timeIntervalSince(startDate)
                task.startDate = nil
                task.endDate = previousEndDate.addingTimeInterval(duration)
                arr.append(task)
                previousEndDate = task.endDate
//                print("inlined \(startDate)")
            } else {
                arr.append(task)
                previousEndDate = task.endDate
            }
        }
        return arr
    }
    
    private func removeUntrackableTasks (_ tasks: [Task]) -> [Task] {
        
        var arr = [Task]()
        var untrackedDuration = 0.0
        var previousTaskOriginalEndDate = tasks.first!.endDate
        
        for task in tasks {
            if isTrackingAllowed(taskType: task.taskType) {
                var tempTask = task
                tempTask.endDate = task.endDate.addingTimeInterval(-untrackedDuration)
                arr.append(tempTask)
            } else {
                untrackedDuration += task.endDate.timeIntervalSince(previousTaskOriginalEndDate)
            }
            previousTaskOriginalEndDate = task.endDate
        }
        return arr
    }
    
    private func addExtraTimeToTasks (_ tasks: [Task], targetHoursInDay: Double?) -> [Task] {
        
        // How many tasks should be adjusted
        let numberOfTasksToAdjust = tasks.filter({ isAdjustable(taskType: $0.taskType) }).count
        
        guard numberOfTasksToAdjust > 0 else {
            return tasks
        }
        
        // Calculate the diff to targetHoursInDay
        let workedTime = tasks.last!.endDate.timeIntervalSince(tasks.first!.endDate)
        let requiredHours = targetHoursInDay != nil ? targetHoursInDay! : workedTime
        let missingTime = requiredHours - workedTime
        let extraTimePerTask = ceil( Double( Int(missingTime) / numberOfTasksToAdjust))
        
        var roundedTasks = [Task]()
        
        var task = tasks.first!
        task.endDate = task.endDate.round()
        roundedTasks.append(task)
        var previousDate = task.endDate
        var extraTimeToAdd = 0.0
        
        for i in 1..<tasks.count-1 {
            
            task = tasks[i]
            
            if targetHoursInDay != nil && isAdjustable(taskType: task.taskType) {
                extraTimeToAdd += extraTimePerTask
            }
            
            task.endDate = task.endDate.addingTimeInterval(extraTimeToAdd).round()
            task.startDate = previousDate
            previousDate = task.endDate
            
            roundedTasks.append(task)
        }
        
        // Handle the last task separately, add the remaining time till targetHoursInDay
        task = tasks.last!
        task.endDate = roundedTasks.first!.endDate.addingTimeInterval(requiredHours)
        task.startDate = previousDate
        roundedTasks.append(task)
        
        return roundedTasks
    }
    
    private func groupByTaskNumber (_ tasks: [Task]) -> (groups: [String: [Task]], order: [String]) {
        
        var order = [String]()
        var groups = [String: [Task]]()
        for task in tasks {
            guard isDisplayingAllowed(taskType: task.taskType) else {
                continue
            }
            let taskNumber = task.taskNumber ?? ""
            // Save to dictionary
            var tgroup: [Task]? = groups[taskNumber]
            if tgroup == nil {
                tgroup = [Task]()
                groups[taskNumber] = tgroup
            }
            tgroup?.append(task)
            groups[taskNumber] = tgroup!
            // Save order
            if !order.contains(taskNumber) {
                order.append(taskNumber)
            }
        }
        
        return (groups: groups, order: order)
    }
    
    private func reportsFromGroups (_ groups: [String: [Task]]) -> [Report] {
        
        var reportsMap = [String: Report]()
        
        for (taskNumber, tasks) in groups {
            
            for task in tasks {
                
                guard isTrackingAllowed(taskType: task.taskType) else {
                    continue
                }
                guard let startDate = task.startDate else {
                    // This shouldn't happen. It can happen only if there's no start of the day
                    continue
                }
                
                var report = reportsMap[taskNumber]
                
                if report == nil {
                    
                    var title = task.taskTitle
                    let comps = title?.components(separatedBy: taskNumber)
                    title = comps?.last
                    title = title?.replacingOccurrences(of: "_", with: " ")
                    title = title?.replacingOccurrences(of: "-", with: " ")
                    
                    report = Report(
                        taskNumber: taskNumber,
                        title: title ?? "",
                        notes: "• \(task.notes ?? "")",
                        duration: task.endDate.timeIntervalSince(startDate)
                    )
                } else {
                    report!.duration += task.endDate.timeIntervalSince(task.startDate!)
                    if !report!.notes.contains(task.notes ?? "") {
                        report!.notes = "\(report!.notes)\n• \(task.notes ?? "")"
                    }
                }
                reportsMap[taskNumber] = report
            }
        }
        
        return Array(reportsMap.values)
	}
    
    private func sortReports (_ reports: [Report], withOrder order: [String]) -> [Report] {
        
        var orderedReports = [Report]()
        
        // TODO: sort the array with short lambdas if possible
//        let arr = reports.sorted { reports.index(of: $0) < order.index(of: $1.1) }
        
        for taskNumber in order {
            for report in reports {
                if report.taskNumber == taskNumber {
                    orderedReports.append(report)
                }
            }
        }
        
        return orderedReports
    }
}

extension CreateReport {
    
    private func isTrackingAllowed (taskType: TaskType) -> Bool {
        switch taskType {
            case .lunch, .waste: return false
            default: return true
        }
    }
    
    /// Returns if the duration of this task type is adjustable
    private func isAdjustable (taskType: TaskType) -> Bool {
        switch taskType {
            case .startDay, .scrum, .meeting, .learning, .calendar: return false
            default: return true
        }
    }
    
    private func isDisplayingAllowed (taskType: TaskType) -> Bool {
        return taskType != .startDay
    }
}

//
//  CreateReport.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class CreateReport {
    
    func reports (fromTasks tasks: [Task], targetSeconds: Double?) -> [CombinedReports] {

        var processedTasks = removeUnsavedTasksIfNeeded(tasks)
        processedTasks = removeEndOfDay(processedTasks)

        // We need at least one other task beside the startDay to create a report
        guard processedTasks.count > 1 else {
			return []
        }
        processedTasks = flattenTasks(processedTasks)
        processedTasks = removeUntrackableTasks(processedTasks)
        // We need at least one task beside the startDay to create a report
        guard processedTasks.count > 1 else {
            return []
        }
        if let targetSeconds {
            processedTasks = addExtraTimeToTasks(processedTasks, targetSeconds: targetSeconds)
        }
        processedTasks = fillTasksWithStartDates(processedTasks)
        // Remove .startDay because it is not part of the report
        processedTasks = processedTasks.filter({ $0.taskType != .startDay })

        let groups = groupByTaskNumber(processedTasks)
        let reports = reportsFromGroups(groups.groups)
        
        return sortReports(reports, withOrder: groups.order)
	}
}

extension CreateReport {
    
    private func removeUnsavedTasksIfNeeded (_ tasks: [Task]) -> [Task] {
        // Eliminate unsaved tasks if the day was ended by the user
        // There might be duplicated calendar events
        guard tasks.contains(where: { $0.taskType == .endDay }) else {
            return tasks
        }
        return tasks.filter({ $0.objectId != nil })
    }

    // Removes the end of day and everything that follows after
    private func removeEndOfDay (_ tasks: [Task]) -> [Task] {
        var isEndFound = false
        return tasks.filter({
            if !isEndFound {
                isEndFound = $0.taskType == .endDay
            }
            return !isEndFound
        })
    }

    // Arrange the tasks in order and move overlappings
    private func flattenTasks (_ tasks: [Task]) -> [Task] {

        var arr = [Task]()
        var task = tasks.first!
        var previousEndDate = task.endDate
        arr.append(task)
        
        for i in 1..<tasks.count {
            
            task = tasks[i]
            
            if let startDate = task.startDate {
                // Tasks with start and end date are inlined tasks.
                // Extract them in front of the overlapped task. This will take from the time of the actual task
                let duration = task.endDate.timeIntervalSince(startDate)
                task.startDate = nil
                task.endDate = previousEndDate.addingTimeInterval(duration)
            }
            arr.append(task)
            previousEndDate = task.endDate
        }
        return arr
    }
    
    private func removeUntrackableTasks (_ tasks: [Task]) -> [Task] {
        
        var arr = [Task]()
        var untrackedDuration = 0.0
        var previousTaskOriginalEndDate = tasks.first!.endDate
        
        for task in tasks {
            if task.taskType.isTrackable {
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
    
    private func addExtraTimeToTasks (_ tasks: [Task], targetSeconds: Double) -> [Task] {

        // How many tasks should be adjusted
        let nrOfAdjustableTasks = tasks.filter({ $0.taskType.isDurationAdjustable }).count
        guard nrOfAdjustableTasks > 0 else {
            return tasks
        }

        // Calculate the nr of seconds of non-adjustable tasks
//        var nonAdjustableTasksSeconds: Double = 0
//        for i in 1..<tasks.count {
//            if !tasks[i].taskType.isDurationAdjustable {
//                nonAdjustableTasksSeconds += tasks[i].endDate.timeIntervalSince(tasks[i-1].endDate)
//            }
//        }

        // Calculate the diff to targetHoursInDay
        let workedSeconds = tasks.last!.endDate.timeIntervalSince(tasks.first!.endDate)
//        let adjustableSeconds = workedSeconds - nonAdjustableTasksSeconds
        let requiredSeconds = targetSeconds
//        let requiredAdjustableSeconds = requiredSeconds - nonAdjustableTasksSeconds
        // Distribute the missing seconds equaly to the nr of adjustable tasks
        let missingSeconds = requiredSeconds - workedSeconds
        let extraSecondsPerTask = ceil( Double( Int(missingSeconds) / nrOfAdjustableTasks))
        print(">>>>> extraSecondsPerTask:\(extraSecondsPerTask) missingSeconds:\(missingSeconds)")

        var roundedTasks = [Task]()
        
        // First task is start of the day and should not be modified
        var refTask = tasks.first!
        roundedTasks.append(refTask)
        var shiftedTime = 0.0

        for i in 1..<tasks.count {
            var task = tasks[i]
            // Shift the date to the right
            print(">>>>> original date \(i) \(task.endDate) shiftedTime:\(shiftedTime)")
            task.endDate = task.endDate.addingTimeInterval(shiftedTime)
            print(">>>>> new date after shifting \(i) \(task.endDate)")

            if task.taskType.isDurationAdjustable {
                let initialEndDate: Date = task.endDate
                let newEndDate = task.endDate.addingTimeInterval(extraSecondsPerTask)
//                newEndDate = newEndDate.round()
                let roundedExtraTime = newEndDate.timeIntervalSince(initialEndDate)
                shiftedTime += roundedExtraTime
                task.endDate = newEndDate.round()
                if task.endDate.timeIntervalSince(refTask.endDate) < 15.minToSec {
                    task.endDate = task.endDate.addingTimeInterval(15.minToSec)
                }
                print(">>>>> adding time to editable task \(i) \(initialEndDate) \(newEndDate) rounded:\(task.endDate)")
            }
            refTask = task

            roundedTasks.append(task)
        }
        
        // If target time was not reached or it surpased, find the first adjustable Task and adjust acordingly
        let achievedSeconds = roundedTasks.last!.endDate.timeIntervalSince(roundedTasks.first!.endDate)
        if achievedSeconds != requiredSeconds {
            let surplusTime = achievedSeconds - requiredSeconds
            var canAdjust = false
            for i in 1..<roundedTasks.count {
                if roundedTasks[i].taskType.isDurationAdjustable || canAdjust {
                    roundedTasks[i].endDate = roundedTasks[i].endDate.addingTimeInterval(-surplusTime)
                    canAdjust = true
                }
                print(">>>>> \(i) <<<<<< \(roundedTasks[i].endDate)")
            }
        }
        
        return roundedTasks
    }

    private func fillTasksWithStartDates (_ tasks: [Task]) -> [Task] {

        var previousStartDate = tasks.first!.endDate

        return tasks.map({
            if $0.taskType == .startDay {
                return $0
            }
            var task = $0
            task.startDate = previousStartDate
            previousStartDate = task.endDate
            return task
        })
    }

    private func groupByTaskNumber (_ tasks: [Task]) -> (groups: [String: [Task]], order: [String]) {
        
        var order = [String]()
        var groups = [String: [Task]]()
        for task in tasks {
            guard isDisplayingAllowed(taskType: task.taskType) else {
                continue
            }
            let taskNumber = task.taskNumber != nil && task.taskNumber != ""
                ? task.taskNumber!
                : (task.taskType.defaultTaskNumber ?? "")
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
    
    private func reportsFromGroups (_ groups: [String: [Task]]) -> [CombinedReports] {

        var reportsMap = [String: CombinedReports]()

        for (taskNumber, tasks) in groups {
            
            for task in tasks {
                
                guard task.taskType.isTrackable else {
                    continue
                }
                guard let startDate = task.startDate else {
                    // This shouldn't happen, all tasks are processed to have a start date.
                    // It can happen only if there's no start of the day
                    continue
                }
                
                var report = reportsMap[taskNumber]
                
                if report == nil {
                    // New reports
                    var title = task.taskTitle
                    let comps = title?.components(separatedBy: taskNumber)
                    title = comps?.last
                    title = title?.replacingOccurrences(of: "_", with: " ")
                    title = title?.replacingOccurrences(of: "-", with: " ")
                    var notes = [String]()
                    if let taskNotes = task.notes {
                        notes = [taskNotes]
                    }
                    report = CombinedReports(
                        taskNumber: taskNumber,
                        title: title ?? "",
                        notes: notes,
                        duration: task.endDate.timeIntervalSince(startDate)
                    )
                } else {
                    // Update existing reports
                    report!.duration += task.endDate.timeIntervalSince(task.startDate!)
                    if let taskNotes = task.notes {
                        var notes = report!.notes
                        if !notes.contains(taskNotes) {
                            notes.append(taskNotes)
                            report!.notes = notes
                        }
                    }
                }
                reportsMap[taskNumber] = report
            }
        }
        
        return Array(reportsMap.values)
	}
    
    private func sortReports (_ reports: [CombinedReports], withOrder order: [String]) -> [CombinedReports] {

        var orderedReports = [CombinedReports]()

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
    
    private func isDisplayingAllowed (taskType: TaskType) -> Bool {
        return taskType != .startDay
    }
}

//
//  CreateMonthReport.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class CreateMonthReport {

    private let createReport = CreateReport()

    /// Returns reports collected from all days in the month
    /// @parameters
    /// tasks - All tasks in a month
    func reports (fromTasks tasks: [Task], targetHoursInDay: Double?) -> (byDays: [[Report]], byTasks: [Report]) {

        guard tasks.count > 1 else {
            return (byDays: [], byTasks: [])
        }
        // When we find a startDay we keep its date and start adding tasks in that day till endDay found or new startDay found
        // Tasks between end and start are invalid
        var startDayDate: Date?

        // Group tasks by days
        var tasksByDay = [[Task]]()
        var tasksInDay = [Task]()
        for task in tasks {
            if let date = startDayDate {
                // Start of day already found
                // Iterate till endDay or new day found
                if task.taskType == .endDay {
                    tasksInDay.append(task)
                    tasksByDay.append(tasksInDay)
                    tasksInDay = []
                    startDayDate = nil
                } else if !date.isSameDayAs(task.endDate) {
                    tasksByDay.append(tasksInDay)
                    tasksInDay = [task]
                    startDayDate = task.endDate
                } else {
                    tasksInDay.append(task)
                }
            } else {
                // If no start of day found yet iterate till found
                if task.taskType == .startDay {
                    startDayDate = task.endDate
                    tasksInDay = [task]
                }
            }
            if task.objectId == tasks.last?.objectId && tasksInDay.count > 0 {
                tasksByDay.append(tasksInDay)
            }
        }

        // Iterate over days and create reports
        var reportsByDay = [[Report]]()
        for tasks in tasksByDay {
            let report = createReport.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
            reportsByDay.append(report)
        }

        // Group reports by task number
        // Acumulate durations
        // Join notes but only for meetings
        var reportsByTaskNumber = [String: Report]()
        for day in reportsByDay {
            for report in day {
                var monthReport = reportsByTaskNumber[report.taskNumber]
                if monthReport == nil {
                    reportsByTaskNumber[report.taskNumber] = Report(taskNumber: report.taskNumber,
                                                                    title: report.title,
                                                                    notes: ["meeting", "learning"].contains(report.taskNumber) ? report.notes : [],
                                                                    duration: report.duration)
                } else {
                    if ["meeting", "learning"].contains(report.taskNumber)  {
                        monthReport!.notes = Array(Set(monthReport!.notes + report.notes))
                    }
                    monthReport!.duration += report.duration
                    reportsByTaskNumber[report.taskNumber] = monthReport
                }
            }
        }

        return (byDays: reportsByDay, byTasks: Array(reportsByTaskNumber.values))
    }
    
    func joinReports (_ reports: [Report]) -> (notes: String, totalDuration: Double) {
        
        var notes = ""
        var totalDuration = 0.0
        for report in reports {
            totalDuration += report.duration
            notes += "• \(report.taskNumber)\(report.title) (" + report.duration.secToHoursAndMin + ")\n"
        }
        return (notes: notes, totalDuration: totalDuration)
    }
}

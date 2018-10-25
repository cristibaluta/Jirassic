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
    func reports (fromTasks tasks: [Task], targetHoursInDay: Double?) -> [Report] {

        guard var referenceDate = tasks.first?.endDate else {
            return []
        }

        // Group tasks by days
        var tasksByDay = [[Task]]()
        var tasksInDay = [Task]()
        for task in tasks {
            if referenceDate.isSameDayAs(task.endDate) {
                tasksInDay.append(task)
            } else {
                tasksByDay.append(tasksInDay)
                tasksInDay = []
                tasksInDay.append(task)
                referenceDate = task.endDate
            }
            if task.objectId == tasks.last?.objectId {
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
                                                                    notes: report.taskNumber == "meeting" ? report.notes : [],
                                                                    duration: report.duration)
                } else {
                    if report.taskNumber == "meeting" {
                        monthReport!.notes = Array(Set(monthReport!.notes + report.notes))
                    }
                    monthReport!.duration += report.duration
                    reportsByTaskNumber[report.taskNumber] = monthReport
                }
            }
        }

        return Array(reportsByTaskNumber.values)
    }
    
    func joinReports (_ reports: [Report]) -> (notes: String, totalDuration: Double) {
        
        var notes = ""
        var totalDuration = 0.0
        for report in reports {
            totalDuration += report.duration
            notes += "• \(report.taskNumber)\(report.title) (" + report.duration.secToHoursAndMinutesFormatted + ")\n"
        }
        return (notes: notes, totalDuration: totalDuration)
    }
}

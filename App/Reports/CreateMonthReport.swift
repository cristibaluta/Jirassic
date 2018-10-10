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
        for task in tasks {
            var t = [Task]()
            if referenceDate.isSameDayAs(task.endDate) {
                t.append(task)
            } else {
                referenceDate = task.endDate
                tasksByDay.append(t)
                t = []
                t.append(task)
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
        // Do not add notes
        var reportsByTaskNumber = [String: Report]()
        for day in reportsByDay {
            for report in day {
                var r = reportsByTaskNumber[report.taskNumber]
                if r == nil {
                    reportsByTaskNumber[report.taskNumber] = Report(taskNumber: report.taskNumber,
                                                                    title: report.title,
                                                                    notes: "",
                                                                    duration: report.duration)
                } else {
                    r?.duration += report.duration
                    reportsByTaskNumber[report.taskNumber] = r
                }
            }
        }

        return Array(reportsByTaskNumber.values)
    }
}

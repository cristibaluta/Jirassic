//
//  CreateMonthReport.swift
//  Jirassic
//
//  Created by Cristian Baluta on 09/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

class MonthReportFormatter {

    private let headers = [
        "Issue Key", "Issue summary", "Hours", "Work date", "Username", "Full name",
        "Period", "Account Key", "Account Name", "Activity Name", "Component", "All Components",
        "Version Name", "Issue Type", "Issue Status", "Project Key", "Project Name",
        "Work Description", "Parent Key", "Reporter", "External Hours", "Billed Hours",
        "Issue Original Estimate", "Issue Remaining Estimate", "Epic Link",
        "Account [deprecated, this field is no longer being used]", "Office Space", "External issue ID",
        "External issue ID", "Department", "Location", "External issue summary", "External Issue ID",
        "External Issue ID"
    ]

    private let createReport = CreateReport()

    /// Returns reports collected from all days in the month
    /// @parameters
    /// tasks - All tasks in a month
    /// targetHoursInDay - How many hours in a day
    func reports (fromTasks tasks: [Task],
                  targetSecondsInDay: Double?) -> (byDays: [[Report]], byTasks: [Report], csv: String) {

        guard tasks.count > 1 else {
            return (byDays: [], byTasks: [], csv: "")
        }
        var csv = headers.joined(separator: ";") + "\n"
        // When we find a startDay we keep its date and start adding tasks in that day till endDay found or new startDay found
        // Tasks between end and start of next day are invalid
        var referenceDate: Date?

        // Group tasks by days
        var tasksByDay = [[Task]]()
        var tasksInDay = [Task]()

        for i in 0..<tasks.count {
            let task = tasks[i]
            guard let date = referenceDate else {
                // If no start of day found yet iterate till found
                if task.taskType == .startDay {
                    referenceDate = task.endDate
                    tasksInDay = [task]
                }
                continue
            }
            if date.isSameDayAs(task.endDate) {
                tasksInDay.append(task)
            } else {
                // We found a task that does not belong to the previous day
                // If the previous day does not contain any task with adjustable duration
                // Find the first task from one of the next days
                let isAdjustable = tasksInDay.contains(where: { $0.taskType.isDurationAdjustable })
                if !isAdjustable {
                    if let adjustableTask = Array(tasks[i...]).first(where: { $0.taskType.isDurationAdjustable }) {
                        tasksInDay.append(adjustableTask)
                    }
                }
                tasksByDay.append(tasksInDay)

                if task.taskType == .startDay {
                    tasksInDay = [task]
                    referenceDate = task.endDate
                } else {
                    tasksInDay = []
                    referenceDate = nil
                }
            }
            // We reach the end of all tasks so close the day
            if task.objectId == tasks.last?.objectId && task.objectId != nil && tasksInDay.count > 0 {
                tasksByDay.append(tasksInDay)
            }
        }

        // Iterate over days and create reports
        var reportsByDay = [[Report]]()
        for tasks in tasksByDay {
            let report = createReport.reports(fromTasks: tasks, targetSeconds: targetSecondsInDay)
            reportsByDay.append(report)
        }

        // Group reports by task number
        // Acumulate durations
        // Join notes
        var reportsByTaskNumber = [String: Report]()
        var d = 0.0
        for day in reportsByDay {
            var d1 = 0.0
            for report in day {
                d += report.duration
                d1 += report.duration
                var taskReport = reportsByTaskNumber[report.taskNumber]
                if taskReport == nil {
                    reportsByTaskNumber[report.taskNumber] = Report(taskNumber: report.taskNumber,
                                                                    title: report.title,
                                                                    notes: report.notes,//["meeting", "learning"].contains(report.taskNumber) ? report.notes : [],
                                                                    duration: report.duration)
                } else {
                    taskReport!.notes = Array(Set(taskReport!.notes + report.notes))
                    taskReport!.duration += report.duration
                    reportsByTaskNumber[report.taskNumber] = taskReport
                }
            }
            print(">>>>>>>>>>> duration of day \(d1)")
        }
        print(">>>>>>>>>>> duration of month \(d)")

        return (byDays: reportsByDay, byTasks: Array(reportsByTaskNumber.values), csv: csv)
    }

    /// List of reports by task number
    func joinReports (_ reports: [Report]) -> (notes: String, totalDuration: Double) {
        
        var notes = ""
        var totalDuration = 0.0
        for report in reports {
            totalDuration += report.duration
            notes += "• \(report.taskNumber)\(report.title) (" + report.duration.secToHoursAndMin + ")\n"
            if report.notes.count > 0 {
                for note in report.notes {
                    notes += "    - \(note)\n"
                }
            }
        }
        return (notes: notes, totalDuration: totalDuration)
    }

    func csvReports (_ reports: [Report]) -> String {

        var csv = headers.joined(separator: ";") + "\n"
        // Iterate over reports
        for report in reports {
            if report.notes.count > 0 {
                var duration = report.duration.secToHours
                for note in report.notes {
                    csv += buildLine(duration: duration,
                                     taskNumber: report.taskNumber,
                                     title: report.title,
                                     note: note)
                    csv += "\n"
                    duration = 0
                }
            } else {
                csv += buildLine(duration: report.duration.secToHours,
                                 taskNumber: report.taskNumber,
                                 title: report.title,
                                 note: "")
                csv += "\n"
            }
        }
        return csv
    }

    private func buildLine(duration: Double, taskNumber: String, title: String, note: String) -> String {
        var descr = "\(taskNumber) \(title == "" ? note : title)"
        if taskNumber == "meeting" {
            descr = note
        }
        let dict = [
            "Hours": "\(duration)",
            "Component": taskNumber == "meeting" ? "Meetings" : "",
            "Project Name": "GS1.1_BOSCH_eBike",
            "Work Description": descr
        ]
        var line = ""
        for h in headers {
            line += (dict[h] ?? "") + ";"
        }

        return line
    }
}

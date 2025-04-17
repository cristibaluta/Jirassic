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
                  targetSecondsInDay: Double?) -> (byDays: [[CombinedReports]], byTasks: [CombinedReports], csv: String) {

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
                let isAnyTaskAdjustable = tasksInDay.contains(where: { $0.taskType.isDurationAdjustable })
                if !isAnyTaskAdjustable {
                    if var nextAdjustableTask = Array(tasks[i...]).first(where: { $0.taskType.isDurationAdjustable }) {
                        // Change the date to the current day
                        let startDate = tasksInDay.first!.endDate
                        nextAdjustableTask.startDate = nil
                        nextAdjustableTask.endDate = startDate.addingTimeInterval(9.hoursToSec)
                        tasksInDay.append(nextAdjustableTask)
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
        }
        // We reach the end of all tasks so add the last tasksInDay to the array
        if tasksInDay.count > 0 {
            tasksByDay.append(tasksInDay)
        }

        // Iterate over days and create reports
        var reportsByDay = [[CombinedReports]]()
        for tasks in tasksByDay {
            let reports = createReport.reports(fromTasks: tasks, targetSeconds: targetSecondsInDay)
            reportsByDay.append(reports)

            for report in reports {
                let lines = buildCsvLines(duration: report.duration.secToHours,
                                          taskNumber: report.taskNumber,
                                          title: report.title,
                                          notes: report.notes)
                lines.forEach({ line in
                    csv += line
                    csv += "\n"
                })
            }
        }

        // Group reports by task number
        // Acumulate durations
        // Join notes
        var reportsByTaskNumber = [String: CombinedReports]()
        var d = 0.0
        for day in reportsByDay {
            var d1 = 0.0
            for report in day {
                d += report.duration
                d1 += report.duration
                var taskReport = reportsByTaskNumber[report.taskNumber]
                if taskReport == nil {
                    reportsByTaskNumber[report.taskNumber] = CombinedReports(taskNumber: report.taskNumber,
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
    func joinReports (_ reports: [CombinedReports]) -> (notes: String, totalDuration: Double) {
        
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

    // Create one entry for each note
    // Duration is added only to the first entry, the rest are filled with 0, so the total will be as for all notes
    private func buildCsvLines (duration: Double, taskNumber: String, title: String, notes: [String]) -> [String] {
        print(">>>>> notes \(notes)")
        var duration = duration
        return notes.map {
            defer {
                duration = 0
            }
            return buildCsvLine(duration: duration, taskNumber: taskNumber, title: title, note: $0)
        }
    }

    private func buildCsvLine (duration: Double, taskNumber: String, title: String, note: String) -> String {

        var descr = "\(taskNumber) \(title == "" ? note : title)"
        if taskNumber == "meeting" {
            descr = note
        }
        let dict = [
            "Hours": "\(duration)",
            "Component": taskNumber == "meeting" ? "Meetings" : "",
            "Project Name": "GS1.1_BOSCH_eBike",
            "Work Description": descr.replacingOccurrences(of: ";", with: " ")
        ]
        var line = ""
        for h in headers {
            line += (dict[h] ?? "") + ";"
        }
        print(">>>>> line \(line)")

        return line
    }
}

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
    /// targetHoursInDay - How many hours in a day
    /// roundHours - Round the reports to fixed hours
    func reports (fromTasks tasks: [Task],
                  targetHoursInDay: Double?,
                  roundHours: Bool) -> (byDays: [[Report]], byTasks: [Report]) {

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
                // Iterate till endDay or new startDay found
                // Days without a .startDay are ignored
                if task.taskType == .endDay {
                    tasksInDay.append(task)
                    tasksByDay.append(tasksInDay)
                    tasksInDay = []
                    startDayDate = nil
                } else if !date.isSameDayAs(task.endDate) {
                    // This task is from the next day
                    tasksByDay.append(tasksInDay)
                    tasksInDay = [task]
                    startDayDate = task.taskType == .startDay ? task.endDate : nil
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
            var d = 0.0
            for report in day {
                d += report.duration
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

    // List of reports by task number
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
    
    func htmlReports (_ reports: [Report]) -> String {
        
        var notes = ""
        var totalDuration = 0.0
        for report in reports {
            totalDuration += report.duration
            var note = "\(report.taskNumber) \(report.title)"
            if report.notes.count > 0 {
                note = "<p>\(note)</p>"
                note += "<ul>"
                for n in report.notes {
                    note += "<li>\(n)</li>"
                }
                note += "</ul>"
            }
            notes += "<tr><td style=\"text-align: left; padding-left: 10px;\">\(note)</td><td>\(report.duration.secToHoursAndMin)</td></tr>\n"
        }
        return notes
    }

    func csvReports (_ reports: [Report]) -> String {

        let headers = [
            "Issue Key", "Issue summary", "Hours", "Work date", "Username", "Full name",
            "Period", "Account Key", "Account Name", "Activity Name", "Component", "All Components",
            "Version Name", "Issue Type", "Issue Status", "Project Key", "Project Name",
            "Work Description", "Parent Key", "Reporter", "External Hours", "Billed Hours",
            "Issue Original Estimate", "Issue Remaining Estimate", "Epic Link",
            "Account [deprecated, this field is no longer being used]", "Office Space", "External issue ID",
            "External issue ID", "Department", "Location", "External issue summary", "External Issue ID",
            "External Issue ID"
        ]
        var csv = headers.joined(separator: ";") + "\n"
        for report in reports {
            var note = "\(report.taskNumber) \(report.title)"
            var component = ""
            if report.notes.count > 0 {
                for n in report.notes {
                    csv += ";;\(report.duration.secToHours);;;;;;;;\(component);;;;;;GS1.1_BOSCH_eBike;\(note);;;;;;;;;;;;;;;;"
                    csv += "\n"
                }
            } else {
                csv += ";;\(report.duration.secToHours);;;;;;;;;;;;;;GS1.1_BOSCH_eBike;\(note);;;;;;;;;;;;;;;;"
                csv += "\n"
            }
        }
        return csv
    }
}

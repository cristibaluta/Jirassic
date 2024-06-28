//
//  CreateDayReport.swift
//  Jirassic
//
//  Created by Cristian Baluta on 13.06.2024.
//  Copyright © 2024 Imagin soft. All rights reserved.
//

import Foundation

class DayReportFormatter {

    func stringReports (_ reports: [Report]) -> String {

        var str = ""
        for report in reports {
            let notes: [String] = report.notes.compactMap { note in
                guard note.count > 0 else {
                    return nil
                }
                return "• \(note)"
            }
            var taskNumber = report.taskNumber == "coderev" ? "Code reviews and fixes" : report.taskNumber
            taskNumber = taskNumber == "learning" ? "Learning" : taskNumber
            taskNumber = taskNumber == "meeting" ? "Meetings" : taskNumber
            var title = report.title
                .replacingOccurrences(of: "_", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if report.taskNumber == "learning" || report.taskNumber == "meeting" {
                title = ""
            }

            var note = "(\(report.duration.secToHours)) \(taskNumber) \(title)"
            if report.notes.count > 0 {
                for n in notes {
                    note += "\n      \(n)"
                }
            }
            str += note + "\n"
        }
        return str
    }

    func toString (_ reports: [Report]) -> String  {
        let lines = reports.map({ (_ report: Report) -> String in
            let title = self.title(from: report)
            let notes = report.notes.map { (note) -> String in
                return "• \(note)"
            }
            let body = notes.joined(separator: "\n")
            return title + "\n" + body
        })
        return lines.joined(separator: "\n\n")
    }

    private func title (from report: Report) -> String {
        let taskNumber = report.taskNumber
        let taskTitle = report.title
        switch taskNumber {
        case "meeting": return "Meetings:"
        case "coderev": return ""
        default:
            switch taskTitle {
            case "": return taskNumber
            default: return taskNumber + " - " + taskTitle
            }
        }
    }
}

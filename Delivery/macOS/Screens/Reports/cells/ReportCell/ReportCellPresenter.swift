//
//  ReportCellPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/11/2016.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Cocoa
import RCPreferences

class ReportCellPresenter: NSObject {
    
    var cell: CellProtocol!
    private let pref = RCPreferences<LocalPreferences>()
    
    convenience init (cell: CellProtocol) {
        self.init()
        self.cell = cell
    }
    
    func present (theReport: Report) {

        let notes = theReport.notes.map { (note) -> String in
            return "• \(note)"
        }
        let notesJoined = notes.joined(separator: "\n")
        var taskNumber = theReport.taskNumber == "coderev" ? "Code reviews" : theReport.taskNumber
        taskNumber = taskNumber == "learning" ? "Learning" : taskNumber
        taskNumber = taskNumber == "meeting" ? "Meetings" : taskNumber
        let title = theReport.title.replacingOccurrences(of: "_", with: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        cell.data = (
            dateStart: nil,
            dateEnd: Date(),
            taskNumber: taskNumber + "  " + title,
            notes: notesJoined,
            taskType: .issue,
            projectId: nil
        )
        cell.duration = pref.bool(.usePercents)
            ? "\(theReport.duration.secToPercent)"
            : theReport.duration.secToHoursAndMin// Date(timeIntervalSince1970: theReport.duration).HHmmGMT()
        cell.statusImage?.image = NSImage(named: NSImage.statusAvailableName)
        cell.isDark = AppDelegate.sharedApp().theme.isDark
    }
}

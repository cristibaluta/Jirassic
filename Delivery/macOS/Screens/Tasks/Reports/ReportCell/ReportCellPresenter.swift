//
//  ReportCellPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 06/11/2016.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Cocoa

class ReportCellPresenter: NSObject {
    
    var cell: CellProtocol!
    
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
            taskType: .issue
        )
        let localPreferences = RCPreferences<LocalPreferences>()
        cell.duration = localPreferences.bool(.usePercents) 
            ? "\(Date.secondsToPercentTime(theReport.duration))"
            : theReport.duration.secToHoursAndMin// Date(timeIntervalSince1970: theReport.duration).HHmmGMT()
        cell.statusImage?.image = NSImage(named: NSImage.Name.statusAvailable)
        cell.isDark = AppDelegate.sharedApp().theme.isDark
    }
}

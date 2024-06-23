//
//  TaskCellPresenter.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCellPresenter: NSObject {

	var cell: CellProtocol!
	
	convenience init (cell: CellProtocol) {
		self.init()
		self.cell = cell
	}
	
    func present (previousTask: Task?, currentTask: Task, lastTask: Task?) {
		
        cell.statusImage?.image = nil
        
        switch currentTask.taskType {
        case .issue:
            cell.statusImage?.image = NSImage(named: NSImage.statusAvailableName)
            
        case .gitCommit:
            cell.statusImage?.image = NSImage(named: "GitIcon")
            
        case .coderev:
            cell.color = NSColor.systemGray
            
        case .startDay, .endDay:
            cell.color = NSColor.systemBlue
            
        case .calendar:
            cell.color = NSColor.systemGray
            cell.statusImage?.image = NSImage(named: "CalendarIcon")
            
        default:
            cell.color = NSColor.systemGray
        }

        var notes = currentTask.notes ?? ""
        if notes == "" {
            notes = currentTask.taskType.defaultNotes
        }
        // The codereview notes is a list of tasks that were reviewed
        if currentTask.taskType == .coderev && currentTask.notes != nil && currentTask.notes != "" {
            notes = "\(currentTask.taskType.defaultNotes): \(notes)"
        }
        if currentTask.taskType == .lunch {
            notes = currentTask.taskType.defaultNotes
        }
		cell.data = (
            dateStart: currentTask.startDate,
            dateEnd: currentTask.endDate,
			taskNumber: currentTask.taskNumber,
            notes: notes,
			taskType: currentTask.taskType,
            projectId: currentTask.projectId
		)
        cell.isDark = AppDelegate.sharedApp().theme.isDark
        cell.isEditable = currentTask.isSaved && false
        cell.isRemovable = currentTask.isSaved
        cell.isIgnored = currentTask.taskType == .lunch || currentTask.taskType == .waste
        cell.timeToolTip = currentTask.isSaved ? "Click to edit" : "Item can be edited after the day is closed"
	}
}

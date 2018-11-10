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
	
	func present (previousTask: Task?, currentTask theTask: Task) {
		
        cell.statusImage?.image = nil
        
        switch theTask.taskType {
        case .issue:
            cell.statusImage?.image = NSImage(named: NSImage.Name.statusAvailable)
            
        case .gitCommit:
            cell.statusImage?.image = NSImage(named: NSImage.Name(rawValue: "GitIcon"))
            
        case .coderev:
            cell.color = NSColor.lightGray
            
        case .startDay, .endDay:
            cell.color = NSColor.blue
            
        case .calendar:
            cell.statusImage?.image = NSImage(named: NSImage.Name(rawValue: "CalendarIcon"))
            
        default:
            break
        }
		
		cell.data = (
            dateStart: theTask.startDate,
            dateEnd: theTask.endDate,
			taskNumber: theTask.taskNumber ?? theTask.taskType.defaultNotes,
            notes: theTask.notes ?? theTask.taskType.defaultNotes,
			taskType: theTask.taskType
		)
        cell.isDark = AppDelegate.sharedApp().theme.isDark
        cell.isEditable = theTask.taskType != .gitCommit && theTask.taskType != .calendar
        cell.isRemovable = theTask.objectId != nil
        cell.isIgnored = theTask.taskType == .lunch || theTask.taskType == .waste
	}
}

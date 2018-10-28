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
		
		var statusImage: NSImage?
		
        switch theTask.taskType {
            
        case .issue:
            statusImage = NSImage(named: NSImage.Name.statusAvailable)
            break
            
        case .gitCommit:
            statusImage = NSImage(named: NSImage.Name(rawValue: "GitIcon"))
            break
            
        case .coderev:
            cell.color = NSColor.lightGray
            statusImage = nil
            
        case .startDay, .endDay:
            cell.color = NSColor.blue
            statusImage = nil
            
        case .calendar:
            statusImage = NSImage(named: NSImage.Name(rawValue: "CalendarIcon"))
            
        default:
            statusImage = nil
        }
		
		cell.data = (
            dateStart: theTask.startDate,
            dateEnd: theTask.endDate,
			taskNumber: theTask.taskNumber ?? "",
			notes: theTask.notes ?? theTask.taskType.defaultNotes,
			taskType: .issue
		)
        cell.statusImage?.image = statusImage
        cell.isDark = AppDelegate.sharedApp().theme.isDark
        cell.isEditable = theTask.taskType != .gitCommit
        cell.isIgnored = theTask.taskType == .lunch || theTask.taskType == .waste
	}
}

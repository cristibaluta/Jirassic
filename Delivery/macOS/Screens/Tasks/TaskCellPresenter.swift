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
		
//		var duration = ""
		var statusImage: NSImage?
		
        if let _ = previousTask {
            // When we have a previous item to compare dates with
            switch theTask.taskType {
                
                case TaskType.issue:
//                    let diff = theTask.endDate.timeIntervalSince(thePreviosData.endDate as Date)
//                    duration = Date(timeIntervalSince1970: diff).HHmmGMT()
                    statusImage = NSImage(named: NSImage.Name.statusAvailable)
                    break
                    
                case TaskType.gitCommit:
//                    let diff = theTask.endDate.timeIntervalSince(thePreviosData.endDate as Date)
//                    duration = Date(timeIntervalSince1970: diff).HHmmGMT()
                    statusImage = NSImage(named: NSImage.Name(rawValue: "GitIcon"))
                    break
                    
                default:
                    statusImage = NSImage(named: NSImage.Name.statusUnavailable)
            }
        } else {
            statusImage = nil
        }
		
		cell.data = (
            dateStart: theTask.startDate,
            dateEnd: theTask.endDate,
			taskNumber: theTask.taskNumber ?? "",
			notes: theTask.notes ?? "",
			taskType: .issue
		)
//		cell.duration = duration
        cell.statusImage?.image = statusImage
        cell.isDark = AppDelegate.sharedApp().theme.isDark
	}
}

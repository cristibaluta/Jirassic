//
//  TaskCellPresenter.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCellPresenter: NSObject {

	var cell: CellProtocol?
	
	convenience init (cell: CellProtocol) {
		self.init()
		self.cell = cell
	}
	
	func presentData (theData: Task, andPreviousData previousData: Task?) {
		
		var duration = ""
		var statusImage: NSImage?
		
        if let thePreviosData = previousData {
            // When we have a previous item to compare dates with
            switch (Int(theData.taskType.intValue)) {
                
            case TaskType.Issue.rawValue:
                let diff = theData.endDate.timeIntervalSinceDate(thePreviosData.endDate)
                duration = NSDate(timeIntervalSince1970: diff).HHmmGMT()
                statusImage = NSImage(named: NSImageNameStatusAvailable)
                break
                
            case TaskType.GitCommit.rawValue:
                let diff = theData.endDate.timeIntervalSinceDate(thePreviosData.endDate)
                duration = NSDate(timeIntervalSince1970: diff).HHmmGMT()
                statusImage = NSImage(named: "GitIcon")
                break
                
            default:
                statusImage = NSImage(named: NSImageNameStatusUnavailable)
            }
        } else {
            // This is always the first cell
            statusImage = nil
        }
		
		cell?.data = (
			dateEnd: theData.endDate,
			taskNumber: theData.taskNumber ?? "",
			notes: theData.notes ?? ""
		)
		cell?.duration = duration
		cell?.statusImage?.image = statusImage
	}
}

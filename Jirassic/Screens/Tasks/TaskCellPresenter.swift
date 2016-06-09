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
		
		var dateEnd: NSDate = NSDate()
		var duration = ""
		var notes = theData.notes ?? ""// TODO: Alert the user the notes can't be nil
		var statusImage: NSImage?
		
        if let thePreviosData = previousData {
            // When we have a previous item to compare dates with
            switch (Int(theData.taskType.intValue)) {
                
            case TaskType.Issue.rawValue:
                let endDate = theData.endDate
                let diff = endDate.timeIntervalSinceDate(thePreviosData.endDate)
                duration = NSDate(timeIntervalSince1970: diff).HHmmGMT()
                dateEnd = endDate
                statusImage = NSImage(named: NSImageNameStatusAvailable)
                break
                
            case TaskType.GitCommit.rawValue:
                let endDate = theData.endDate
                let diff = endDate.timeIntervalSinceDate(thePreviosData.endDate)
                duration = NSDate(timeIntervalSince1970: diff).HHmmGMT()
                dateEnd = endDate
                statusImage = NSImage(named: "GitIcon")
                break
                
            default:
                let endDate = theData.endDate
                dateEnd = endDate
                statusImage = NSImage(named: NSImageNameStatusUnavailable)
            }
        } else {
            // This is always the first cell
            notes = "\(notes) at \(theData.endDate.HHmm())"
            statusImage = nil
        }
		
		cell?.data = (
			dateEnd: dateEnd,
			issueType: theData.issueType ?? "",
			issueId: theData.issueId ?? "",
			notes: notes
		)
		cell?.duration = duration
		cell?.statusImage!.image = statusImage
	}
}

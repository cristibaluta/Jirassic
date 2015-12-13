//
//  TaskCellPresenter.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TaskCellPresenter: NSObject {

	var cell: TaskCellProtocol?
	
	convenience init(cell: TaskCellProtocol) {
		self.init()
		self.cell = cell
	}
	
	func presentData (theData: Task, andPreviousData previousData: Task?) {
		
		var dateStart = ""
		var dateEnd = ""
		var duration = ""
		var notes = theData.notes ?? ""//Alert the user the notes can't be nil
		var statusImage: NSImage?
		
		if theData.endDate == nil && theData.startDate != nil {
			dateStart = theData.startDate!.HHmm()
			statusImage = NSImage(named: NSImageNameStatusPartiallyAvailable)
		}
		else {
			if let thePreviosData = previousData {
				// When we have a previous item to compare dates with
				switch (Int(theData.taskType!.intValue)) {
					
					case TaskType.Issue.rawValue:
						if let endDate = theData.endDate {
							let diff = endDate.timeIntervalSinceDate(thePreviosData.endDate!)
							duration = NSDate(timeIntervalSince1970: diff).HHmmGMT()
							dateEnd = endDate.HHmm()
							dateStart = thePreviosData.endDate!.HHmm()
							statusImage = NSImage(named: NSImageNameStatusAvailable)
						} else {
//							dateEnd = theData.endDate!.HHmm()
							statusImage = NSImage(named: NSImageNameStatusPartiallyAvailable)
						}
						break
					
					default:
						dateEnd = theData.endDate!.HHmm()
						dateStart = thePreviosData.endDate!.HHmm()
						statusImage = nil
				}
			} else {
				// This is always the Start cell
				notes = "\(notes) at \(theData.endDate!.HHmm())"
				statusImage = nil
			}
		}
		
		cell?.data = (dateStart: dateStart, dateEnd: dateEnd, issue: theData.issueType ?? "", notes: notes)
		cell?.duration = duration
		cell?.statusImage!.image = statusImage
	}
}

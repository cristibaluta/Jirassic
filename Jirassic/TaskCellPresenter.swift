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
		
		var date = ""
		var notes = theData.notes ?? ""//Alert the user the notes can't be nil
		var statusImage: NSImage?
		
		if theData.endDate == nil && theData.startDate != nil {
			date = theData.startDate!.HHmm()
			statusImage = NSImage(named: NSImageNameStatusPartiallyAvailable)
		} else {
			if let thePreviosData = previousData {
				if Int(theData.taskType!.intValue) == TaskType.Issue.rawValue {
					if let dateEnd = theData.endDate {
						let duration = dateEnd.timeIntervalSinceDate(thePreviosData.endDate!)
						date = "\(dateEnd.HHmm())\n\(NSDate(timeIntervalSince1970: duration).HHmmGMT())h"
						statusImage = NSImage(named: NSImageNameStatusAvailable)
					} else {
						date = "\(theData.endDate!.HHmm())\n..."
						statusImage = NSImage(named: NSImageNameStatusPartiallyAvailable)
					}
				} else {
					date = "\(thePreviosData.endDate!.HHmm()) - \(theData.endDate!.HHmm())"
					statusImage = nil
				}
			} else {
				// This is always the Start cell
				notes = "\(notes) at \(theData.endDate!.HHmm())"
				statusImage = nil
			}
		}
		
		cell?.data = (dateStart: date, dateEnd: date, issue: theData.issueType ?? "", notes: notes)
		cell?.statusImage!.image = statusImage
	}
}

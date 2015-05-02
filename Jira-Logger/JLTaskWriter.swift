//
//  JLWriteLog.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class JLTaskWriter: NSObject {

	override init() {
		
	}
	
	func write(task_id: String, notes: String) -> Task {
		let theData = Task()
		theData.date_task_finished = NSDate()
		theData.notes = notes
		theData.task_nr = task_id
		theData.saveInBackgroundWithBlock { (success, error) -> Void in
			println("saved task to Parse \(success) \(error)")
		}
		return theData
	}
}

//
//  JLWriteLog.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class JLWriteLog: NSObject {

	override init() {
		
	}
	
	func write() {
		let theData = JiraData()
		theData.date_task_finished = NSDate()
		theData.notes = "task 3452, fixed by deleting the project"
		theData.saveInBackgroundWithBlock { (success, error) -> Void in
			println("saved")
			println(success)
			println(error)
		}
	}
}

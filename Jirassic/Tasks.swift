//
//  Tasks.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/09/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

class Tasks: NSObject {
	
	class func taskFromDate(dateSart: NSDate?, dateEnd: NSDate?, type: TaskType) -> TaskProtocol {
		
		let task = Task()
		task.date_task_started = dateSart
		task.date_task_finished = dateEnd
		task.issue_type = Issues.lastUsed()
		task.task_type = type.rawValue
		task.user = JRUser.currentUser()!
		
		switch (type) {
			case TaskType.Issue: task.notes = ""
			case TaskType.Start: task.notes = "Working day started"
			case TaskType.Scrum: task.notes = "Scrum session"
			case TaskType.Lunch: task.notes = "Lunch break"
			case TaskType.Meeting: task.notes = "Internal meeting"
		}
		
		return task
	}
	
	class func taskFromSubtype(subtype: TaskSubtype) -> TaskProtocol {
		
		switch(subtype) {
			case .IssueBegin: return taskFromDate(NSDate(), dateEnd: nil, type: TaskType.Issue)
			case .IssueEnd: return taskFromDate(nil, dateEnd: NSDate(), type: TaskType.Issue)
			case .ScrumBegin: return taskFromDate(NSDate(), dateEnd: nil, type: TaskType.Scrum)
			case .ScrumEnd: return taskFromDate(nil, dateEnd: NSDate(), type: TaskType.Scrum)
			case .LunchBegin: return taskFromDate(NSDate(), dateEnd: nil, type: TaskType.Lunch)
			case .LunchEnd: return taskFromDate(nil, dateEnd: NSDate(), type: TaskType.Lunch)
			case .MeetingBegin: return taskFromDate(NSDate(), dateEnd: nil, type: TaskType.Meeting)
			case .MeetingEnd: return taskFromDate(nil, dateEnd: NSDate(), type: TaskType.Meeting)
		}
	}
}

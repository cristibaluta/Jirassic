//
//  Task.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

enum TaskType: Int {
	
	case Issue = 0
	case Start = 1
	case Scrum = 2
	case Lunch = 3
	case Meeting = 4
}

enum TaskSubtype: Int {
	
	case IssueBegin = 0
	case IssueEnd = 1
	case ScrumBegin = 2
	case ScrumEnd = 3
	case LunchBegin = 4
	case LunchEnd = 5
	case MeetingBegin = 6
	case MeetingEnd = 7
}

struct Task {
	
	var startDate: NSDate?
	var endDate: NSDate?
	var notes: String?
	var issueType: String?
	var taskType: NSNumber?
	var objectId: String?
}

extension Task {
	
	init (dateSart: NSDate?, dateEnd: NSDate?, type: TaskType) {
		
		self.startDate = dateSart
		self.endDate = dateEnd
		self.issueType = Issues.lastUsed()
		self.taskType = type.rawValue
		
		switch (type) {
		case TaskType.Issue: self.notes = ""
		case TaskType.Start: self.notes = "Working day started"
		case TaskType.Scrum: self.notes = "Scrum session"
		case TaskType.Lunch: self.notes = "Lunch break"
		case TaskType.Meeting: self.notes = "Internal meeting"
		}
	}
	
	init (subtype: TaskSubtype) {
		
		switch(subtype) {
		case .IssueBegin:	self.startDate = NSDate(); self.taskType = TaskType.Issue.rawValue
		case .IssueEnd:		self.endDate = NSDate(); self.taskType = TaskType.Issue.rawValue
		case .ScrumBegin:	self.startDate = NSDate(); self.taskType = TaskType.Scrum.rawValue
		case .ScrumEnd:		self.endDate = NSDate(); self.taskType = TaskType.Scrum.rawValue
		case .LunchBegin:	self.startDate = NSDate(); self.taskType = TaskType.Lunch.rawValue
		case .LunchEnd:		self.endDate = NSDate(); self.taskType = TaskType.Lunch.rawValue
		case .MeetingBegin: self.startDate = NSDate(); self.taskType = TaskType.Meeting.rawValue
		case .MeetingEnd:	self.endDate = NSDate(); self.taskType = TaskType.Meeting.rawValue
		}
	}
}

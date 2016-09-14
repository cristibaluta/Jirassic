//
//  Task.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

enum TaskType: Int {
	
	case issue = 0
	case startDay = 1
	case scrum = 2
	case lunch = 3
	case meeting = 4
	case gitCommit = 5
}

enum TaskSubtype: Int {
	
//	case IssueBegin = 0
	case issueEnd = 1
//	case ScrumBegin = 2
	case scrumEnd = 3
//	case LunchBegin = 4
	case lunchEnd = 5
//	case MeetingBegin = 6
	case meetingEnd = 7
	case gitCommitEnd = 8
}

struct Task {
	
	var endDate: Date
	var notes: String?
	var taskNumber: String?
	var taskType: NSNumber
	var taskId: String
}

extension Task {
	
    init () {
        self.endDate = Date()
        self.taskType = NSNumber(value: TaskType.issue.rawValue)
        self.taskId = String.random()
    }
    
	init (dateEnd: Date, type: TaskType) {
		
		self.endDate = dateEnd
		self.taskNumber = nil
		self.taskType = NSNumber(value: type.rawValue)
        self.taskId = String.random()
		
		switch (type) {
			case TaskType.issue:	self.notes = ""
			case TaskType.startDay:	self.notes = "Working day started"
			case TaskType.scrum:	self.notes = "Scrum meeting"
			case TaskType.lunch:	self.notes = "Lunch break"
			case TaskType.meeting:	self.notes = "Internal meeting"
			case TaskType.gitCommit:self.notes = ""
		}
	}
	
	init (subtype: TaskSubtype) {
		
        self.endDate = Date()
        self.taskId = String.random()
        
		switch (subtype) {
			case .issueEnd:		self.taskType = NSNumber(value: TaskType.issue.rawValue)
			case .scrumEnd:		self.taskType = NSNumber(value: TaskType.scrum.rawValue)
			case .lunchEnd:		self.taskType = NSNumber(value: TaskType.lunch.rawValue)
			case .meetingEnd:	self.taskType = NSNumber(value: TaskType.meeting.rawValue)
			case .gitCommitEnd:	self.taskType = NSNumber(value: TaskType.gitCommit.rawValue)
		}
	}
}

typealias TaskCreationData = (
    dateEnd: Date,
    taskNumber: String,
    notes: String
)

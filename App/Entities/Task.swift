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
    case nap = 6
    case learning = 7
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
//    case napBegin = 9
    case napEnd = 10
    //    case learningBegin = 11
    case learningEnd = 12
}

struct Task {
    
    var startDate: Date?
	var endDate: Date
	var notes: String?
	var taskNumber: String?
	var taskType: TaskType
	var objectId: String
}

extension Task {
	
    init () {
        self.endDate = Date()
        self.taskType = TaskType.issue
        self.objectId = String.random()
    }
    
	init (dateEnd: Date, type: TaskType) {
		
		self.endDate = dateEnd
		self.taskNumber = nil
		self.taskType = type
        self.objectId = String.random()
		
		switch (type) {
			case TaskType.issue:	self.notes = ""
			case TaskType.startDay:	self.notes = "Working day started"
			case TaskType.scrum:	self.notes = "Scrum meeting"
			case TaskType.lunch:	self.notes = "Lunch break"
			case TaskType.meeting:	self.notes = "Internal meeting"
            case TaskType.gitCommit:self.notes = ""
            case TaskType.nap:      self.notes = "Nap, I was tired"
            case TaskType.learning: self.notes = "Learning session"
		}
	}
	
	init (subtype: TaskSubtype) {
		
        self.endDate = Date()
        self.objectId = String.random()
        
		switch (subtype) {
			case .issueEnd:		self.taskType = TaskType.issue
			case .scrumEnd:		self.taskType = TaskType.scrum
			case .lunchEnd:		self.taskType = TaskType.lunch
			case .meetingEnd:	self.taskType = TaskType.meeting
            case .gitCommitEnd:	self.taskType = TaskType.gitCommit
            case .napEnd:       self.taskType = TaskType.nap
            case .learningEnd:  self.taskType = TaskType.learning
		}
	}
}

typealias TaskCreationData = (
    dateStart: Date?,
    dateEnd: Date,
    taskNumber: String,
    notes: String
)

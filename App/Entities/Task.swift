//
//  Task.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

// Never change the indexes because they are stored in the database
enum TaskType: Int {
	
	case issue = 0
	case startDay = 1
	case scrum = 2
	case lunch = 3
	case meeting = 4
    case gitCommit = 5
    case waste = 6
    case learning = 7
    case coderev = 8
    case endDay = 9
    case calendar = 10
    
    var defaultNotes: String {
        switch self {
        case .startDay: return "Working day started"
        case .scrum: return "Scrum meeting"
        case .lunch: return "Lunch break"
        case .meeting: return "Meeting"
        case .waste: return "Social & Media"
        case .learning: return "Learning session"
        case .coderev: return "Reviewing and fixing code reviews"
        case .calendar: return "Calendar event"
        default: return ""
        }
    }
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
//  case wasteBegin = 9
    case wasteEnd = 10
//  case learningBegin = 11
    case learningEnd = 12
//  case coderevBegin = 13
    case coderevEnd = 14
//    case calendarBegin = 15
    case calendarEnd = 16
    
    var defaultTaskNumber: String? {
        switch self {
            case .scrumEnd: return "scrum"
            case .lunchEnd: return "lunch"
            case .meetingEnd: return "meeting"
            case .wasteEnd: return "waste"
            case .learningEnd: return "learning"
            case .coderevEnd: return "coderev"
            case .calendarEnd: return "meeting"
            default: return nil
        }
    }
}

struct Task {
    
    var lastModifiedDate: Date?
    var startDate: Date?
	var endDate: Date
	var notes: String?
    var taskNumber: String?
    var taskTitle: String?
	var taskType: TaskType
    var objectId: String
}

extension Task {
	
    init () {
        self.endDate = Date()
        self.taskType = TaskType.issue
        self.objectId = String.random()
    }
    
	init (endDate: Date, type: TaskType) {
		
		self.endDate = endDate
		self.taskType = type
        self.objectId = String.random()
        
        var subtype: TaskSubtype?
		
		switch (type) {
			case TaskType.issue:	subtype = .issueEnd
			case TaskType.startDay:	break
            case TaskType.endDay:   break
			case TaskType.scrum:	subtype = .scrumEnd
			case TaskType.lunch:	subtype = .lunchEnd
			case TaskType.meeting:	subtype = .meetingEnd
            case TaskType.gitCommit:subtype = .gitCommitEnd
            case TaskType.waste:    subtype = .wasteEnd
            case TaskType.learning: subtype = .learningEnd
            case TaskType.coderev:  subtype = .coderevEnd
            case TaskType.calendar: subtype = .calendarEnd
        }
        if let s = subtype {
            self.taskNumber = s.defaultTaskNumber
        }
	}
	
	init (subtype: TaskSubtype) {
		
        self.endDate = Date()
        self.objectId = String.random()
        self.taskNumber = subtype.defaultTaskNumber
        
		switch (subtype) {
			case .issueEnd:		self.taskType = TaskType.issue
			case .scrumEnd:		self.taskType = TaskType.scrum
			case .lunchEnd:		self.taskType = TaskType.lunch
			case .meetingEnd:	self.taskType = TaskType.meeting
            case .gitCommitEnd:	self.taskType = TaskType.gitCommit
            case .wasteEnd:     self.taskType = TaskType.waste
            case .learningEnd:  self.taskType = TaskType.learning
            case .coderevEnd:   self.taskType = TaskType.coderev
            case .calendarEnd:  self.taskType = TaskType.calendar
		}
	}
}

typealias TaskCreationData = (
    dateStart: Date?,
    dateEnd: Date,
    taskNumber: String,
    notes: String,
    taskType: TaskType
)

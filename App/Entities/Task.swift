//
//  Task.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

// Never change the indexes because they are already stored in the database
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
        case .endDay: return "Working day ended"
        case .scrum: return "Scrum meeting"
        case .lunch: return "Lunch break"
        case .meeting: return "Meeting"
        case .waste: return "Social & Media"
        case .learning: return "Learning session"
        case .coderev: return "Reviewing and fixing code"
        case .calendar: return "Calendar event"
        default: return ""
        }
    }
    
    // Used to group reports
    var defaultTaskNumber: String? {
        switch self {
        case .scrum: return "scrum"
        case .lunch: return "lunch"
        case .meeting: return "meeting"
        case .waste: return "waste"
        case .learning: return "learning"
        case .coderev: return "coderev"
        case .calendar: return "meeting"
        default: return nil
        }
    }
}

// Object representing a task
struct Task {
    
    /// Is the date when this object was last modified by the server (iCloud)
    /// When created locally this field does not have a value.
    var lastModifiedDate: Date?
    /// Start date of the task, needed by tasks like meetings which have a known start and end
    var startDate: Date?
	var endDate: Date
	var notes: String?
    /// Task number is the issue number from Jira (eg. AA-1234)
    /// For other type of tasks should be nil
    var taskNumber: String?
    /// Task title is usually the title that follows the task number in Jira
    var taskTitle: String?
	var taskType: TaskType
    /// Created locally and used for matching with the remote object
    /// If objectId is missing means the task is not saved to db nor to server (eg. unsaved git and calendar items)
    var objectId: String?
}

extension Task {
	
    init () {
        self.init (endDate: Date(), type: .issue)
    }
    
	init (endDate: Date, type: TaskType) {
		
		self.endDate = endDate
        self.taskType = type
        self.objectId = String.generateId()
	}
    
    init (startDate: Date?, endDate: Date, type: TaskType) {
        
        self.startDate = startDate
        self.endDate = endDate
        self.taskType = type
        self.objectId = String.generateId()
    }
}

/// Object used to pass task data to and from the cell, for displaying and editing
typealias TaskCreationData = (
    dateStart: Date?,
    dateEnd: Date,
    taskNumber: String?,
    notes: String?,
    taskType: TaskType
)

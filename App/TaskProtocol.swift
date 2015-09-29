//
//  TaskProtocol.swift
//  Jirassic
//
//  Created by Baluta Cristian on 14/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
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

protocol TaskProtocol: NSObjectProtocol {

	var date_task_started: NSDate? {get set}
	var date_task_finished: NSDate? {get set}
	var notes: String? {get set}
	var issue_type: String? {get set}
	var task_type: NSNumber? {get set}
	var user: JRUser? {get set}
	
	func saveToParseWhenPossible()
}

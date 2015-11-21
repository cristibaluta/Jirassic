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
	var user: User?
}

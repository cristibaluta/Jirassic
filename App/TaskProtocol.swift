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
	case TaskIssueBegin = 0
	case TaskIssueEnd = 1
	case TaskScrumBegin = 2
	case TaskScrumEnd = 3
	case TaskLunchBegin = 4
	case TaskLunchEnd = 5
	case TaskMeetingBegin = 6
	case TaskMeetingEnd = 7
}

protocol TaskProtocol: NSObjectProtocol {

	var date_task_started: NSDate? {get set}
	var date_task_finished: NSDate? {get set}
	var notes: String? {get set}
	var task_nr: String? {get set}
	var task_type: NSNumber? {get set}
	var user: PFUser? {get set}
}

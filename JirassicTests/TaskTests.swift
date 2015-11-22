//
//  TasksTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/09/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic

class TaskTests: XCTestCase {
	
    func testTasksFromSubtype() {
		
		XCTAssert(Task(subtype: .IssueBegin).taskType == TaskType.Issue.rawValue, "")
		XCTAssert(Task(subtype: .IssueEnd).taskType == TaskType.Issue.rawValue, "")
		XCTAssert(Task(subtype: .ScrumBegin).taskType == TaskType.Scrum.rawValue, "")
		XCTAssert(Task(subtype: .ScrumEnd).taskType == TaskType.Scrum.rawValue, "")
		XCTAssert(Task(subtype: .LunchBegin).taskType == TaskType.Lunch.rawValue, "")
		XCTAssert(Task(subtype: .LunchEnd).taskType == TaskType.Lunch.rawValue, "")
		XCTAssert(Task(subtype: .MeetingBegin).taskType == TaskType.Meeting.rawValue, "")
		XCTAssert(Task(subtype: .MeetingEnd).taskType == TaskType.Meeting.rawValue, "")
    }
}

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
		
		XCTAssert(Task(subtype: .issueEnd).taskType.intValue == TaskType.issue.rawValue, "")
		XCTAssert(Task(subtype: .scrumEnd).taskType.intValue == TaskType.scrum.rawValue, "")
		XCTAssert(Task(subtype: .lunchEnd).taskType.intValue == TaskType.lunch.rawValue, "")
		XCTAssert(Task(subtype: .meetingEnd).taskType.intValue == TaskType.meeting.rawValue, "")
		XCTAssert(Task(subtype: .gitCommitEnd).taskType.intValue == TaskType.gitCommit.rawValue, "")
    }
}

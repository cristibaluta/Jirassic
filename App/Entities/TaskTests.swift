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
		
		XCTAssert(Task(subtype: .issueEnd).taskType == TaskType.issue)
		XCTAssert(Task(subtype: .scrumEnd).taskType == TaskType.scrum)
		XCTAssert(Task(subtype: .lunchEnd).taskType == TaskType.lunch)
		XCTAssert(Task(subtype: .meetingEnd).taskType == TaskType.meeting)
        XCTAssert(Task(subtype: .gitCommitEnd).taskType == TaskType.gitCommit)
        XCTAssert(Task(subtype: .napEnd).taskType == TaskType.nap)
        XCTAssert(Task(subtype: .learningEnd).taskType == TaskType.learning)
        XCTAssert(Task(subtype: .coderevEnd).taskType == TaskType.coderev)
    }
}

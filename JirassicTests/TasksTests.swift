//
//  TasksTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/09/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import XCTest

class TasksTests: XCTestCase {
	
    func testTasksFromSubtype() {
		let task = Tasks.taskFromSubtype(.IssueBegin)
        XCTAssert(task.task_type == TaskType.Issue.rawValue, "Pass")
    }
}

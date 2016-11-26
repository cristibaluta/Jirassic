//
//  TaskFinderTests.swift
//  Jirassic
//
//  Created by Cristian Baluta on 11/06/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic

class TaskFinderTests: XCTestCase {
    
    func testMissingTasks() {
        
        let tasks = [
            Task(dateEnd: Date(), type: TaskType.issue),
            Task(dateEnd: Date(), type: TaskType.startDay),
            Task(dateEnd: Date(), type: TaskType.meeting),
            Task(dateEnd: Date(), type: TaskType.gitCommit)
        ]
        
        let taskFinder = TaskFinder()
        XCTAssertFalse(taskFinder.scrumExists(tasks))
        XCTAssertFalse(taskFinder.lunchExists(tasks))
    }
    
    func testExistingTasks() {
        
        let tasks = [
            Task(dateEnd: Date(), type: TaskType.issue),
            Task(dateEnd: Date(), type: TaskType.startDay),
            Task(dateEnd: Date(), type: TaskType.scrum),
            Task(dateEnd: Date(), type: TaskType.lunch),
            Task(dateEnd: Date(), type: TaskType.meeting),
            Task(dateEnd: Date(), type: TaskType.gitCommit)
        ]
        
        let taskFinder = TaskFinder()
        XCTAssertTrue(taskFinder.scrumExists(tasks))
        XCTAssertTrue(taskFinder.lunchExists(tasks))
    }
}

//
//  TaskFinderTests.swift
//  Jirassic
//
//  Created by Cristian Baluta on 11/06/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic_no_cloud

class TaskFinderTests: XCTestCase {
    
    func testMissingTasks() {
        
        let tasks = [
            Task(endDate: Date(), type: TaskType.issue),
            Task(endDate: Date(), type: TaskType.startDay),
            Task(endDate: Date(), type: TaskType.meeting),
            Task(endDate: Date(), type: TaskType.gitCommit)
        ]
        
        let taskFinder = TaskFinder()
        XCTAssertFalse(taskFinder.scrumExists(tasks))
        XCTAssertFalse(taskFinder.lunchExists(tasks))
    }
    
    func testExistingTasks() {
        
        let tasks = [
            Task(endDate: Date(), type: TaskType.issue),
            Task(endDate: Date(), type: TaskType.startDay),
            Task(endDate: Date(), type: TaskType.scrum),
            Task(endDate: Date(), type: TaskType.lunch),
            Task(endDate: Date(), type: TaskType.meeting),
            Task(endDate: Date(), type: TaskType.gitCommit)
        ]
        
        let taskFinder = TaskFinder()
        XCTAssertTrue(taskFinder.scrumExists(tasks))
        XCTAssertTrue(taskFinder.lunchExists(tasks))
    }
}

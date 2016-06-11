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

    func testScrumExistence() {
        
        let tasks = [
            Task(dateEnd: NSDate(), type: TaskType.Issue),
            Task(dateEnd: NSDate(), type: TaskType.StartDay),
            Task(dateEnd: NSDate(), type: TaskType.Scrum),
            Task(dateEnd: NSDate(), type: TaskType.Lunch),
            Task(dateEnd: NSDate(), type: TaskType.Meeting),
            Task(dateEnd: NSDate(), type: TaskType.GitCommit)
        ]
        
        let taskFinder = TaskFinder()
        let scrumExists = taskFinder.scrumExists(tasks)
        XCTAssertTrue(scrumExists)
    }

}

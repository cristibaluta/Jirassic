//
//  MergeTasksInteractorTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 20/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic_no_cloud

class MergeTasksInteractorTests: XCTestCase {

    func testMergedOrder() {
        
        var gitWithTaskNumber = Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 16, minute: 30, second: 50), type: .gitCommit)
        gitWithTaskNumber.taskNumber = "APP-1"
        let gitWithoutTaskNumber = Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 16, minute: 30, second: 50), type: .gitCommit)
        var scrum = Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 10, minute: 0, second: 0), type: .calendar)
        scrum.startDate = Date(year: 2018, month: 2, day: 20, hour: 9, minute: 45, second: 0)
        
        let tasks = [Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 9, minute: 0, second: 0), type: .startDay),
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 9, minute: 30, second: 50), type: .issue),
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 13, minute: 10, second: 0), type: .lunch),
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 14, minute: 30, second: 30), type: .gitCommit),
                     gitWithoutTaskNumber,
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 18, minute: 0, second: 0), type: .endDay)
        ]
        let gitTasks = [Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 14, minute: 30, second: 30), type: .gitCommit),// duplicate
                        gitWithTaskNumber,// duplicate
                        gitWithoutTaskNumber,// Duplicate provided by git cmd when you have rebase done
                        Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 18, minute: 0, second: 0), type: .gitCommit)
        ]
        let calendarTasks = [scrum]
        
        var mergedTasks = MergeTasksInteractor().merge(tasks: tasks, with: gitTasks)
        mergedTasks = MergeTasksInteractor().merge(tasks: mergedTasks, with: calendarTasks)
        
        XCTAssert(mergedTasks.count == 8)
        XCTAssert(mergedTasks[0].objectId == tasks[0].objectId, "Should be start of the day")
        XCTAssert(mergedTasks[1].objectId == tasks[1].objectId, "Should be issue 1")
        XCTAssert(mergedTasks[2].objectId == scrum.objectId, "Should be scrum")
        XCTAssert(mergedTasks[3].objectId == tasks[2].objectId, "Should be lunch")
        XCTAssert(mergedTasks[4].objectId == tasks[3].objectId, "Should be first git from tasks")
        XCTAssert(mergedTasks[5].objectId == gitWithTaskNumber.objectId, "Between identical git should be the one with a valid taskNumber")
        XCTAssert(mergedTasks[5].taskNumber == "APP-1")
        XCTAssert(mergedTasks[6].objectId == gitTasks[3].objectId, "Should be last git")
        XCTAssert(mergedTasks[7].objectId == tasks[5].objectId, "Should be end of day")
        
        // Test sorting
        let _ = mergedTasks.sorted { (t1, t2) -> Bool in
            // t1 is the second object and t2 the first from the mergedTasks
            XCTAssert(t1.endDate >= t2.endDate)
            return true
        }
    }
}

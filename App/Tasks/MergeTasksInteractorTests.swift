//
//  MergeTasksInteractorTests.swift
//  JirassicTests
//
//  Created by Cristian Baluta on 20/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

class MergeTasksInteractorTests: XCTestCase {

    func testMerge() {
        
        var gitWithTaskNumber = Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 16, minute: 30, second: 50), type: .gitCommit)
        gitWithTaskNumber.taskNumber = "APP-1"
        let gitWithoutTaskNumber = Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 16, minute: 30, second: 50), type: .gitCommit)
        
        let tasks = [Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 9, minute: 30, second: 50), type: .issue),
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 13, minute: 10, second: 0), type: .lunch),
                     Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 14, minute: 30, second: 30), type: .gitCommit),
                     gitWithoutTaskNumber
        ]
        let gitTasks = [Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 14, minute: 30, second: 30), type: .gitCommit),// duplicate
                        gitWithTaskNumber,// duplicate
                        gitWithoutTaskNumber,// Duplicate provided by git cmd when you have rebase done
                        Task(endDate: Date(year: 2018, month: 2, day: 20, hour: 18, minute: 0, second: 0), type: .gitCommit)
        ]
        
        let mergedTasks = MergeTasksInteractor().merge(tasks: tasks, with: gitTasks)
        
        XCTAssert(mergedTasks.count == 5)
        XCTAssert(mergedTasks[0].endDate.compare(tasks[0].endDate) == .orderedSame)
        XCTAssert(mergedTasks[1].endDate.compare(tasks[1].endDate) == .orderedSame)
        XCTAssert(mergedTasks[2].endDate.compare(tasks[2].endDate) == .orderedSame)
        XCTAssert(mergedTasks[3].endDate.compare(tasks[3].endDate) == .orderedSame)
        XCTAssert(mergedTasks[3].taskNumber == "APP-1")
        XCTAssert(mergedTasks[4].endDate.compare(gitTasks[3].endDate) == .orderedSame)
    }
}

//
//  TaskInteractorTests.swift
//  Jirassic
//
//  Created by Cristian Baluta on 07/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import XCTest
@testable import Jirassic

class TaskInteractorTests: XCTestCase {

    func testSaveDelete() {
        
        let repository = InMemoryCoreDataRepository()
        let interactor = TaskInteractor(data: repository)
        
        let tasksBeforeInsert = repository.queryTasksInDay(NSDate())
        XCTAssert(tasksBeforeInsert.count == 0, "We added one task, we should receive one task")
        
        let task = Task(dateSart: NSDate(), dateEnd: NSDate(), type: TaskType.Issue)
        interactor.saveTask(task)
        
        let tasks = repository.queryTasksInDay(NSDate())
        XCTAssert(tasks.count == 1, "We added one task, we should receive one task")
        
        let taskToDelete = tasks.first!
        interactor.deleteTask(taskToDelete)
        
        let tasksAfterDelete = repository.queryTasksInDay(NSDate())
        XCTAssert(tasksAfterDelete.count == 0, "There should be no tasks left")
    }
}

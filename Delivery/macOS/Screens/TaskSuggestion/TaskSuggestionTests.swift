//
//  TaskSuggestionTests.swift
//  Jirassic
//
//  Created by Cristian Baluta on 10/12/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import XCTest
@testable import Jirassic

fileprivate class TaskSuggestionPresenterMock: TaskSuggestionPresenterOutput {
    var setTaskType_called = false
    var setTime_called = false
    var setNotes_called = false
    var hideTaskTypes_called = false
    func setTaskType (_ taskType: TaskSubtype) { setTaskType_called = true }
    func setTime (_ notes: String) { setTime_called = true }
    func setNotes (_ notes: String) { setNotes_called = true }
    func hideTaskTypes() { hideTaskTypes_called = true }
}

class TaskSuggestionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        localRepository = InMemoryCoreDataRepository()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testMethod_setup() {
        
        let presenter = TaskSuggestionPresenter()
        let controller = TaskSuggestionPresenterMock()
        presenter.userInterface = controller
        
        presenter.setup (startSleepDate: Date(), endSleepDate: Date())
        XCTAssert(controller.setTime_called)
        XCTAssert(controller.setNotes_called)
        XCTAssert(controller.hideTaskTypes_called)
        XCTAssertFalse(controller.setTaskType_called)
    }
    
    func testMethod_setTime() {
        
        let presenter = TaskSuggestionPresenter()
        let controller = TaskSuggestionPresenterMock()
        presenter.userInterface = controller
        
        presenter.selectSegment (atIndex: 0)
        XCTAssertFalse(controller.setTime_called)
        XCTAssertFalse(controller.hideTaskTypes_called)
        XCTAssert(controller.setNotes_called)
        XCTAssert(controller.setTaskType_called)
    }
    
    func testMethod_save() {
        
        let presenter = TaskSuggestionPresenter()
        let controller = TaskSuggestionPresenterMock()
        presenter.userInterface = controller
        
        presenter.save (selectedSegment: 0, notes: "", startSleepDate: Date(), endSleepDate: Date())
//        XCTAssert(controller.setNotes_called)
    }
}

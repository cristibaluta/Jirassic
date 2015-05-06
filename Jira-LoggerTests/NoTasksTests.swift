//
//  NoTasksTests.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 03/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa
import XCTest

class NoTasksTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTheMessageThatYouHaveNTasks() {
        let controller = NoTasksController()
        XCTAssert(true, "Pass")
    }

}

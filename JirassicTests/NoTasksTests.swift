//
//  NoTasksTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 03/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest

class NoTasksTests: XCTestCase {
	
    func testTheMessageThatYouHaveNoTasks() {
        _ = NoTasks()
        XCTAssert(true, "Pass")
    }

}

//
//  RaportTests.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 01/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest

class RaportTests: XCTestCase {

	var tasks = [Task]()
	
    override func setUp() {
        super.setUp()
		
		let t1 = Task(className: Task.parseClassName())
		t1.date_task_finished = NSDate(timeIntervalSince1970: 1433151905) // Mon, 01 Jun 2015 09:45:05 GMT
		let t2 = Task(className: Task.parseClassName())
		t2.date_task_finished = NSDate(timeIntervalSince1970: 1433181605) // Mon, 01 Jun 2015 18:00:05 GMT
		
		tasks = [t1, t2]
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testRoundTo8Hours() {
		
		let raport = JLCreateReport(tasks: self.tasks)
		let firstTask = raport.tasks.first
		let lastTask = raport.tasks.last
		let diff = lastTask?.date_task_finished?.timeIntervalSinceDate(firstTask!.date_task_finished!)
		
		// 28800
		RCLogO(diff)
		
        XCTAssert(diff == kEightHoursInSeconds, "Pass")
    }

	func test8Hours() {
		let date = NSDate()
		let t1 = date.secondsToPercentTime(3600*1.5)
		let t2 = date.secondsToPercentTime(3600*4.0)
		let t3 = date.secondsToPercentTime(15*60.0)
		let t4 = date.secondsToPercentTime(45*60.0)
		let t5 = date.secondsToPercentTime(1800.0)
		let t6 = date.secondsToPercentTime(30*60.0)
		let t7 = date.secondsToPercentTime(30*60.0)
		RCLogO(t1)
		RCLogO(t2)
		RCLogO(t3)
		RCLogO(t4)
		RCLogO(t5)
		RCLogO(t6)
		RCLogO(t7)
		XCTAssertTrue(t1+t2+t3+t4+t5+t6+t7 == 8, "The sum should be 8 hours")
	}
}

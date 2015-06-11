//
//  RaportTests.swift
//  Jirassic
//
//  Created by Baluta Cristian on 01/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import XCTest

class RaportTests: XCTestCase {

	var tasks = [Task]()
	let kLunchLength = Double(2760)//46min ~ 45min
	
    override func setUp() {
        super.setUp()
		
		let t1 = Task(className: Task.parseClassName())
		t1.date_task_finished = NSDate(timeIntervalSince1970: 1433151905) // Mon, 01 Jun 2015 09:45:05 GMT
		
		let t1_1 = Task(className: Task.parseClassName())
		t1_1.date_task_finished = NSDate(timeIntervalSince1970: 1433151905+3985)
		
		let t1_lunch = Task(className: Task.parseClassName())
		t1_lunch.date_task_finished = NSDate(timeIntervalSince1970: Double(1433151905+3985+kLunchLength))
		t1_lunch.task_type = TaskType.Lunch.rawValue
		
		let t1_2 = Task(className: Task.parseClassName())
		t1_2.date_task_finished = NSDate(timeIntervalSince1970: 1433151905+8800)
		
		let t1_3 = Task(className: Task.parseClassName())
		t1_3.date_task_finished = NSDate(timeIntervalSince1970: 1433151905+13980)
		
		let t1_4 = Task(className: Task.parseClassName())
		t1_4.date_task_finished = NSDate(timeIntervalSince1970: 1433181605-8000)
		
		let t2 = Task(className: Task.parseClassName())
		t2.date_task_finished = NSDate(timeIntervalSince1970: 1433181605) // Mon, 01 Jun 2015 18:00:05 GMT
		
		tasks = [t1, t1_1, t1_lunch, t1_2, t1_3, t1_4, t2]
    }
    
    override func tearDown() {
		tasks = []
        super.tearDown()
    }

    func testRoundLessThan8HoursOfWork() {
		
		var tasks = self.tasks
		tasks.removeLast()
		let raport = JLCreateReport(tasks: self.tasks)
		let firstTask = raport.tasks.first
		let lastTask = raport.tasks.last
		let diff = lastTask?.date_task_finished?.timeIntervalSinceDate(firstTask!.date_task_finished!)
		
		// 28800
		RCLogO(diff)
		let date = NSDate(timeIntervalSince1970: kLunchLength).roundUp()
		let adjustedLunchLength = date.timeIntervalSince1970
		RCLogO(adjustedLunchLength)
		
        XCTAssert(diff == kEightHoursInSeconds+adjustedLunchLength, "Pass")
		
//		for i in 1...raport.tasks.count-1 {
//			let task = raport.tasks[i]
//			let prevTask = raport.tasks[i-1]
//			
//			let duration = task.date_task_finished!.timeIntervalSinceDate(prevTask.date_task_finished!)
//			let date = NSDate(timeIntervalSince1970: duration)
//			RCLogO(task.date_task_finished)
//			RCLogO(date.secondsToPercentTime(duration))
//		}
    }
	
	func testRoundMoreThan8HoursOfWork() {
		
		let raport = JLCreateReport(tasks: self.tasks)
		let firstTask = raport.tasks.first
		let lastTask = raport.tasks.last
		let diff = lastTask?.date_task_finished?.timeIntervalSinceDate(firstTask!.date_task_finished!)
		let date = NSDate(timeIntervalSince1970: kLunchLength).roundUp()
		let adjustedLunchLength = date.timeIntervalSince1970
		
		XCTAssert(diff == kEightHoursInSeconds+adjustedLunchLength, "Pass")
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
		XCTAssertTrue(t1+t2+t3+t4+t5+t6+t7 == 8, "The sum should be 8 hours")
	}
}

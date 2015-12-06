//
//  ScriptableApplication.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

extension NSApplication {
	
	func tasks() -> String {
		return "Tasks returned from Jirassic"
	}
	
	func setTasks (tasks: String) {
		RCLog(tasks);
		let task = Task(
			startDate: nil,
			endDate: NSDate(),
			notes: tasks,
			issueType: Issues.lastUsed(),
			taskType: TaskType.Issue.rawValue,
			objectId: nil
		)
		sharedData.updateTask(task, completion: {(success: Bool) -> Void in
			RCLog(success)
		})
	}
	
//	func commit() -> NSDictionary {
//		return (branch: "", message: "")
//	}
	
	func setCommit (commit: NSDictionary) {
		RCLog(commit);
	}
}

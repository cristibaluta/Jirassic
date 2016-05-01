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
	
	func setTasks (message: String) {
        let comps = message.componentsSeparatedByString("::")
        RCLog(comps);
        let notes = comps.last!
        var issueId = comps.first!
        if comps.count < 2 {
            issueId = ""
        }
		let task = Task(
			startDate: nil,
			endDate: NSDate(),
			notes: notes,
			issueType: ReadIssuesInteractor.lastUsed(),
			issueId: issueId,
			taskType: TaskType.GitCommit.rawValue,
			taskId: nil
		)
		localRepository.saveTask(task, completion: {(success: Bool) -> Void in
			RCLog(success)
		})
        
        LocalNotifications().showNotification("Git commit logged to Jirassic", informativeText: notes)
	}
	
	func logCommit (commit: String, ofBranch: String) {
		RCLog(commit)
		RCLog(ofBranch)
	}
}

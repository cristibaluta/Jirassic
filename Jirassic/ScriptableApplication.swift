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
        var taskNumber = comps.first!
        if comps.count < 2 {
            taskNumber = ""
        }
		let task = Task(
			endDate: NSDate(),
			notes: notes,
			taskNumber: taskNumber,
			taskType: TaskType.GitCommit.rawValue,
			taskId: String.random()
		)
        let saveInteractor = TaskInteractor(data: localRepository)
        saveInteractor.saveTask(task)
        
        LocalNotifications().showNotification("Git commit logged to Jirassic", informativeText: notes)
        InternalNotifications.notifyAboutNewlyAddedTask(task)
	}
	
	func logCommit (commit: String, ofBranch: String) {
		RCLog(commit)
		RCLog(ofBranch)
	}
}

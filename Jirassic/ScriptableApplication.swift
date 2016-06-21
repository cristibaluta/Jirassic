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
	
	func setTasks (json: String) {
        
        if let data = json.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                guard let dict = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: String] else {
                    return
                }
                RCLog(dict)
                let notes = dict["notes"] ?? ""
                let taskNumber = dict["taskNumber"] ?? ""
                let taskType = dict["taskType"] != nil ? Int(dict["taskType"]!) : TaskType.GitCommit.rawValue
                let informativeText = "\(taskNumber) \(notes)"
                
                let task = Task(
                    endDate: NSDate(),
                    notes: notes,
                    taskNumber: taskNumber,
                    taskType: taskType!,
                    taskId: String.random()
                )
                let saveInteractor = TaskInteractor(data: localRepository)
                saveInteractor.saveTask(task)
                
                LocalNotifications().showNotification("Git commit logged", informativeText: informativeText)
                InternalNotifications.notifyAboutNewlyAddedTask(task)
            }
            catch let error as NSError {
                RCLogErrorO(error)
            }
        }
	}
	
	func logCommit (commit: String, ofBranch: String) {
		RCLog(commit)
		RCLog(ofBranch)
	}
}

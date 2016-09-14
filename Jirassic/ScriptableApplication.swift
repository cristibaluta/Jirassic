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
	
	func setTasks (_ json: String) {
        
        RCLog(json)
        let validJson = json.replacingOccurrences(of: "'", with: "\"")
        
        if let data = validJson.data(using: String.Encoding.utf8) {
            do {
                guard let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] else {
                    return
                }
                RCLog(dict)
                let notes = dict["notes"] ?? ""
                let branchName = dict["branchName"] ?? ""
                let taskNumber = dict["taskNumber"] != "null" ? dict["taskNumber"]! : branchName
                let taskType = dict["taskType"] != nil ? Int(dict["taskType"]!) : TaskType.gitCommit.rawValue
                let informativeText = "\(taskNumber): \(notes)"
                
                let saveInteractor = TaskInteractor(data: localRepository)
                let reader = ReadTasksInteractor(data: localRepository)
                let currentTasks = reader.tasksInDay(Date())
                if currentTasks.count == 0 {
                    let startDayMark = Task(dateEnd: Date(hour: 9, minute: 0), type: TaskType.startDay)
                    saveInteractor.saveTask(startDayMark)
                }
                
                let task = Task(
                    endDate: Date(),
                    notes: notes,
                    taskNumber: taskNumber,
                    taskType: NSNumber(value: taskType!),
                    taskId: String.random()
                )
                saveInteractor.saveTask(task)
                
                LocalNotifications().showNotification("Git commit logged", informativeText: informativeText)
                InternalNotifications.notifyAboutNewlyAddedTask(task)
            }
            catch let error as NSError {
                RCLogErrorO(error)
            }
        }
	}
	
	func logCommit (_ commit: String, ofBranch: String) {
		RCLog(commit)
		RCLog(ofBranch)
	}
}

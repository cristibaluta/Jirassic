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
                let taskTitle = dict["branchName"] ?? ""
                let taskNumber = dict["taskNumber"] != "null" ? dict["taskNumber"]! : taskTitle
                let taskType = dict["taskType"] != nil
                    ? TaskType(rawValue: Int(dict["taskType"]!)!)!
                    : TaskType.gitCommit
                let informativeText = "\(taskNumber): \(notes)"
                
                let saveInteractor = TaskInteractor(repository: localRepository)
                let reader = ReadTasksInteractor(repository: localRepository)
                let currentTasks = reader.tasksInDay(Date())
                if currentTasks.count == 0 {
                    let settings: Settings = SettingsInteractor().getAppSettings()
                    let startDate = settings.startOfDayTime.dateByKeepingTime()
                    let comps = startDate.components()
                    let startDayMark = Task(dateEnd: Date(hour: comps.hour, minute: comps.minute), type: TaskType.startDay)
                    saveInteractor.saveTask(startDayMark, completion: { savedTask in
                        
                    })
                }
                
                let task = Task(
                    lastModifiedDate: nil,
                    startDate: nil,
                    endDate: Date(),
                    notes: notes,
                    taskNumber: taskNumber,
                    taskTitle: taskTitle,
                    taskType: taskType,
                    objectId: (local: String.random(), remote: nil)
                )
                saveInteractor.saveTask(task, completion: { savedTask in
                    // Not interested when the the task was saved to server
                })
                
                UserNotifications().showNotification("Git commit added", informativeText: informativeText)
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

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
        
        guard let data = validJson.data(using: String.Encoding.utf8) else {
            return
        }
        guard let jdict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String], let dict = jdict else {
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
        
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        let reader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
        let currentTasks = reader.tasksInDay(Date())
        if currentTasks.count == 0 {
            let settings: Settings = SettingsInteractor().getAppSettings()
            let startDate = settings.settingsTracking.startOfDayTime.dateByKeepingTime()
            let comps = startDate.components()
            let startDayMark = Task(endDate: Date(hour: comps.hour, minute: comps.minute), type: TaskType.startDay)
            saveInteractor.saveTask(startDayMark, allowSyncing: true, completion: { savedTask in
                
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
            objectId: String.random()
        )
        saveInteractor.saveTask(task, allowSyncing: true, completion: { savedTask in
            
        })
        
        UserNotifications().showNotification("Git commit added", informativeText: informativeText)
        InternalNotifications.notifyAboutNewlyAddedTask(task)
	}
	
	func logCommit (_ commit: String, ofBranch: String) {
		RCLog(commit)
		RCLog(ofBranch)
	}
}

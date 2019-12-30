//
//  NewTaskCommand.swift
//  Jirassic
//
//  Created by Cristian Baluta on 08/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences
import RCLog

class NewTaskCommand: NSScriptCommand {
    
    let pref = RCPreferences<LocalPreferences>()
    
    override func execute() -> Any? {
        
        guard pref.bool(.enableJit) else {
            RCLogErrorO("Jit is not enabled.")
            return nil
        }
        guard let json = arguments?[""] as? String else {
            RCLogErrorO("Invalid argument")
            return nil
        }
        RCLog(json)
        let validJson = json.replacingOccurrences(of: "'", with: "\"")
        
        guard let data = validJson.data(using: String.Encoding.utf8) else {
            return nil
        }
        guard let jdict = ((try? JSONSerialization.jsonObject(with: data, options: []) as? [String: String]) as [String : String]??), let dict = jdict else {
            return nil
        }
        RCLog(dict)
        let notes = dict["notes"] ?? ""
        let taskTitle = dict["branchName"] ?? ""
        let taskNumber = dict["taskNumber"] != "null" ? dict["taskNumber"]! : taskTitle
        let taskType = dict["taskType"] != nil
            ? TaskType(rawValue: Int(dict["taskType"]!)!)!
            : TaskType.gitCommit
        let informativeText = "\(taskNumber): \(notes)"
        
        // If the day was not started, start it now
        let reader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
        let currentTasks = reader.tasksInDay(Date())
        if currentTasks.count == 0 {
            startDay()
        }
        
        // Save task
        let task = Task(
            lastModifiedDate: nil,
            startDate: nil,
            endDate: Date(),
            notes: notes,
            taskNumber: taskNumber,
            taskTitle: taskTitle,
            taskType: taskType,
            objectId: String.generateId()
        )
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(task, allowSyncing: true, completion: { savedTask in
            
        })
        
        // Notify app
        UserNotifications().showNotification("Git commit added", informativeText: informativeText)
        InternalNotifications.notifyAboutNewlyAddedTask(task)
        
        return nil
    }
    
    private func startDay() {
        
        var startDate = AppDelegate.sharedApp().sleep.lastWakeDate
        if startDate == nil {
            let settings: Settings = SettingsInteractor().getAppSettings()
            startDate = settings.settingsTracking.startOfDayTime.dateByKeepingTime()
        }
        let comps = startDate!.components()
        let startDayMark = Task(endDate: Date(hour: comps.hour, minute: comps.minute), type: TaskType.startDay)
        
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(startDayMark, allowSyncing: true, completion: { savedTask in
            
        })
    }
}

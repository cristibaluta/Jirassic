//
//  ComputerWakeUpInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ComputerWakeUpInteractor: RepositoryInteractor {
    
	func runWithLastSleepDate (_ date: Date?) {
		
		let reader = ReadTasksInteractor(repository: self.repository)
		let existingTasks = reader.tasksInDay(Date())
        let settings: Settings = SettingsInteractor().getAppSettings()
        let typeEstimator = TaskTypeEstimator()
        
        guard existingTasks.count > 0 else {
            let estimatedType: TaskType = typeEstimator.taskTypeAroundDate(Date(), withSettings: settings)
            if estimatedType == .startDay && settings.autoTrackStartOfDay {
                log(taskType: TaskType.startDay)
            }
            return
        }
        
        let estimatedType: TaskType = typeEstimator.taskTypeAroundDate(date!, withSettings: settings)
        
        switch estimatedType {
        case .scrum:
            if settings.autoTrackScrum && !TaskFinder().scrumExists(existingTasks) {
                log(taskType: TaskType.scrum)
            }
            break
        case .lunch:
            if settings.autoTrackLunch && !TaskFinder().scrumExists(existingTasks) {
                log(taskType: TaskType.lunch)
            }
            break
        case .meeting:
            //                if settings.autoTrackMeetings {
            log(taskType: TaskType.meeting)
            //                }
            break
        default:
            break
        }
	}

    func log (taskType: TaskType) {
        
        let task = Task(dateEnd: Date(), type: taskType)
        let saveInteractor = TaskInteractor(repository: localRepository)
        saveInteractor.saveTask(task)
        InternalNotifications.notifyAboutNewlyAddedTask(task)
    }
}

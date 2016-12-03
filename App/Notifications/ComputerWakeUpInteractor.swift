//
//  ComputerWakeUpInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ComputerWakeUpInteractor: RepositoryInteractor {
    
	func runWith (lastSleepDate date: Date?) {
		
        guard let date = date else {
            return
        }
		let reader = ReadTasksInteractor(repository: self.repository)
		let existingTasks = reader.tasksInDay(Date())
        let settings: Settings = SettingsInteractor().getAppSettings()
        let typeEstimator = TaskTypeEstimator()
        
        guard existingTasks.count > 0 else {
            if settings.autoTrackStartOfDay {
                let comps = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.startOfDayTime)
                let startDate = Date().dateByUpdating(hour: comps.hour!, minute: comps.minute!)
                
                if Date() > startDate {
                    save(task: Task(dateEnd: Date(), type: TaskType.startDay))
                }
            }
            return
        }
        
        let estimatedType: TaskType = typeEstimator.taskTypeAroundDate(date, withSettings: settings)
        
        switch estimatedType {
        case .scrum:
            if settings.autoTrackScrum && !TaskFinder().scrumExists(existingTasks) {
                var task = Task(dateEnd: Date(), type: TaskType.scrum)
                task.startDate = date
                save(task: task)
            }
            break
        case .lunch:
            if settings.autoTrackLunch && !TaskFinder().lunchExists(existingTasks) {
                var task = Task(dateEnd: Date(), type: TaskType.lunch)
                task.startDate = date
                save(task: task)
            }
            break
        case .meeting:
            if settings.autoTrackMeetings {
                var task = Task(dateEnd: Date(), type: TaskType.meeting)
                task.startDate = date
                save(task: task)
            }
            break
        default:
            break
        }
	}

    fileprivate func save (task: Task) {
        let saveInteractor = TaskInteractor(repository: localRepository)
        saveInteractor.saveTask(task)
        InternalNotifications.notifyAboutNewlyAddedTask(task)
    }
}

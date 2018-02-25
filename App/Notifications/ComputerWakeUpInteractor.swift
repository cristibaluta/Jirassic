//
//  ComputerWakeUpInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ComputerWakeUpInteractor: RepositoryInteractor {
    
    var settings: Settings!
    let typeEstimator = TaskTypeEstimator()
    let reader: ReadTasksInteractor!
    
    override init (repository: Repository) {
        settings = SettingsInteractor().getAppSettings()
        reader = ReadTasksInteractor(repository: repository)
        super.init(repository: repository)
    }
    
    func runWith (lastSleepDate: Date?, currentDate: Date) {
		
        guard let lastSleepDate = lastSleepDate else {
            return
        }
        if let type = estimationForDate(lastSleepDate, currentDate: currentDate) {
            if type == .startDay {
                if settings.settingsTracking.trackStartOfDay {
                    let startDate = settings.settingsTracking.startOfDayTime.dateByKeepingTime()
                    if currentDate > startDate {
                        let task = Task(endDate: currentDate, type: TaskType.startDay)
                        save(task: task)
                    }
                }
            } else if (type == .scrum && settings.settingsTracking.trackScrum) || (type == .lunch && settings.settingsTracking.trackLunch) {
                
                var task = Task(endDate: currentDate, type: type)
                task.startDate = lastSleepDate
                save(task: task)
            }
        }
    }
    
    func estimationForDate (_ date: Date, currentDate: Date) -> TaskType? {
        
		let existingTasks = reader.tasksInDay(currentDate)
        
        guard existingTasks.count > 0 else {
            return TaskType.startDay
        }
        
        let estimatedType: TaskType = typeEstimator.taskTypeAroundDate(date, withSettings: settings)
        
        switch estimatedType {
        case .scrum:
            if !TaskFinder().scrumExists(existingTasks) {
                return TaskType.scrum
            }
            break
        case .lunch:
            if !TaskFinder().lunchExists(existingTasks) {
                return TaskType.lunch
            }
            break
        case .meeting:
            if settings.settingsTracking.trackMeetings {
                return TaskType.meeting
            }
            break
        default:
            return nil
        }
        return nil
	}
    
    func save (task: Task) {
        let saveInteractor = TaskInteractor(repository: localRepository)
        saveInteractor.saveTask(task, allowSyncing: true, completion: { savedTask in
            InternalNotifications.notifyAboutNewlyAddedTask(savedTask)
        })
    }
}

//
//  ComputerWakeUpInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 27/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ComputerWakeUpInteractor: RepositoryInteractor {
    
    var settings: Settings
    let typeEstimator = TaskTypeEstimator()
    
    override init() {
        settings = SettingsInteractor().getAppSettings()
    }
    
	func runWith (lastSleepDate date: Date?) {
		
        guard let date = date else {
            return
        }
        if let type = estimationForDate(date) {
            if type == .startDay {
                if settings.startOfDayEnabled {
                    let comps = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.startOfDayTime)
                    let startDate = Date().dateByUpdating(hour: comps.hour!, minute: comps.minute!)
                    
                    if Date() > startDate {
                        save(task: Task(dateEnd: Date(), type: TaskType.startDay))
                    }
                }
            } else if (type == .scrum && settings.scrumEnabled) || (type == .lunch && settings.lunchEnabled) {
                
                var task = Task(dateEnd: Date(), type: type)
                task.startDate = date
                save(task: task)
            }
        }
    }
    
    func estimationForDate (_ date: Date) -> TaskType? {
	
        let reader = ReadTasksInteractor(repository: self.repository)
		let existingTasks = reader.tasksInDay(Date())
        
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
            if settings.meetingEnabled {
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
        saveInteractor.saveTask(task)
        InternalNotifications.notifyAboutNewlyAddedTask(task)
    }
}

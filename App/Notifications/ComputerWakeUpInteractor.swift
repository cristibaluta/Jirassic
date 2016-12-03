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
                let comps = gregorian.dateComponents(ymdhmsUnitFlags, from: settings.startOfDayTime)
                let startDate = Date().dateByUpdating(hour: comps.hour!, minute: comps.minute!)
                
                if Date() > startDate {
                    save(task: Task(dateEnd: Date(), type: TaskType.startDay))
                }
            }
            else {
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
            if settings.autoTrackStartOfDay {
                
            }
            return TaskType.startDay
        }
        
        let estimatedType: TaskType = typeEstimator.taskTypeAroundDate(date, withSettings: settings)
        
        switch estimatedType {
        case .scrum:
            if settings.autoTrackScrum && !TaskFinder().scrumExists(existingTasks) {
                return TaskType.scrum
            }
            break
        case .lunch:
            if settings.autoTrackLunch && !TaskFinder().lunchExists(existingTasks) {
                return TaskType.lunch
            }
            break
        case .meeting:
            if settings.autoTrackMeetings {
                return TaskType.meeting
            }
            break
        default:
            return nil
        }
        return nil
	}
    
    fileprivate func save (task: Task) {
        let saveInteractor = TaskInteractor(repository: localRepository)
        saveInteractor.saveTask(task)
        InternalNotifications.notifyAboutNewlyAddedTask(task)
    }
}

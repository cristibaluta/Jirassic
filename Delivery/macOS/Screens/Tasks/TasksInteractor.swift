//
//  TasksInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 22/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

protocol TasksInteractorInput: class {

    func reloadCalendar()
    func reloadTasksOnDay (_ day: Day)
    func reloadTasksOnMonth (_ day: Day)
}

protocol TasksInteractorOutput: class {

    func calendarDidLoad (_ weeks: [Week])
    func tasksDidLoad (_ tasks: [Task])
}

enum ListType: Int {

    case allTasks = 0
    case report = 1
    case monthlyReports = 2
}

class TasksInteractor {

    weak var presenter: TasksPresenter?
    
    private var reader: ReadDaysInteractor?
    private let moduleGit = ModuleGitLogs()
    private let moduleCalendar = ModuleCalendar()
    private let pref = RCPreferences<LocalPreferences>()
    private var currentTasks = [Task]()
}

extension TasksInteractor: TasksInteractorInput {

    func reloadCalendar() {

        reader = ReadDaysInteractor(repository: localRepository, remoteRepository: remoteRepository)
        reader?.query(startingDate: Date(timeIntervalSinceNow: -2.monthsToSec).startOfDay()) { [weak self] weeks in
            DispatchQueue.main.async {
                guard let wself = self else {
                    return
                }
                wself.presenter?.calendarDidLoad(weeks)
            }
        }
    }

    func reloadTasksOnDay (_ day: Day) {

        self.fetchLocalTasks(day) {
            guard !self.currentTasks.isEmpty else {
                self.presenter!.tasksDidLoad (self.currentTasks)
                return
            }
            self.fetchGitLogs(day) {
                self.fetchCalendarEvents(day) {
                    self.presenter!.tasksDidLoad (self.currentTasks)
                }
            }
        }
    }

    func reloadTasksOnMonth (_ day: Day) {

    }

    private func fetchLocalTasks(_ day: Day, completion: () -> Void) {
        let reader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
        let localTasks = reader.tasksInDay(day.dateStart)
        currentTasks = localTasks
        completion()
    }

    private func fetchGitLogs (_ day: Day, completion: @escaping () -> Void) {

        guard pref.bool(.enableGit) else {
            completion()
            return
        }

        moduleGit.logs(onDate: day.dateStart) { [weak self] gitTasks in

            guard let wself = self else {
                return
            }
            wself.currentTasks = MergeTasksInteractor().merge(tasks: wself.currentTasks, with: gitTasks)
            // Filter git commits between start and end tasks
            let startTask = wself.currentTasks.filter({ $0.taskType == .startDay }).first
            let endTask = wself.currentTasks.filter({ $0.taskType == .endDay }).first
            wself.currentTasks = wself.currentTasks.filter({
                if startTask != nil && endTask != nil {
                    return $0.endDate >= startTask!.endDate && $0.endDate <= endTask!.endDate
                } else if startTask != nil {
                    return $0.endDate >= startTask!.endDate
                } else if endTask != nil {
                    return $0.endDate <= endTask!.endDate
                }
                return false
            })

            completion()
        }
    }

    private func fetchCalendarEvents (_ day: Day, completion: @escaping () -> Void) {

        guard pref.bool(.enableCalendar) else {
            completion()
            return
        }

        moduleCalendar.events(onDate: day.dateStart) { [weak self] (calendarTasks) in

            guard let wself = self,
                let startOfDayDate = wself.currentTasks.first?.endDate else {
                    completion()
                    return
            }
            // Keep calendar items between start of day and current date
            let passedCalendarTasks = calendarTasks.filter({
                $0.endDate.compare(Date()) == .orderedAscending &&
                $0.endDate.compare(startOfDayDate) == .orderedDescending
            })

            wself.currentTasks = MergeTasksInteractor().merge(tasks: wself.currentTasks, with: passedCalendarTasks)

            completion()
        }
    }
}

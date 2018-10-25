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
    func reloadTasks (inDay day: Day)
    func reloadTasks (inMonth day: Day)
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

    func reloadTasks (inDay day: Day) {

        let dateStart = day.dateStart
        let dateEnd = day.dateEnd ?? dateStart.endOfDay()
        reloadTasks(dateStart: dateStart, dateEnd: dateEnd)
    }

    func reloadTasks (inMonth day: Day) {

        let dateStart = day.dateStart.startOfMonth()
        let dateEnd = dateStart.endOfMonth()
        reloadTasks(dateStart: dateStart, dateEnd: dateEnd)
    }

    private func reloadTasks (dateStart: Date, dateEnd: Date) {
        
        self.currentTasks = []
        self.addLocalTasks(dateStart: dateStart, dateEnd: dateEnd) {
            guard !self.currentTasks.isEmpty else {
                self.presenter!.tasksDidLoad (self.currentTasks)
                return
            }
            self.addGitLogs(dateStart: dateStart, dateEnd: dateEnd) {
                self.addCalendarEvents(dateStart: dateStart, dateEnd: dateEnd) {
                    self.presenter!.tasksDidLoad (self.currentTasks)
                }
            }
        }
    }
    
    private func addLocalTasks (dateStart: Date, dateEnd: Date, completion: () -> Void) {
        let reader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
        currentTasks = reader.tasks(between: dateStart, and: dateEnd)
        completion()
    }

    private func addGitLogs (dateStart: Date, dateEnd: Date, completion: @escaping () -> Void) {

        guard pref.bool(.enableGit) else {
            completion()
            return
        }
        moduleGit.logs(dateStart: dateStart, dateEnd: dateEnd) { [weak self] gitTasks in

            guard let wself = self else {
                return
            }
            wself.currentTasks = MergeTasksInteractor().merge(tasks: wself.currentTasks, with: gitTasks)
            completion()
        }
    }

    private func addCalendarEvents (dateStart: Date, dateEnd: Date, completion: @escaping () -> Void) {

        guard pref.bool(.enableCalendar) else {
            completion()
            return
        }
        moduleCalendar.events(dateStart: dateStart, dateEnd: dateEnd) { [weak self] (calendarTasks) in

            guard let wself = self else {
                return
            }
            wself.currentTasks = MergeTasksInteractor().merge(tasks: wself.currentTasks, with: calendarTasks)
            completion()
        }
    }
}

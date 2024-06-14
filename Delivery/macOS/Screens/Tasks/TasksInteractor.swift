//
//  TasksInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 22/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences
import RCLog

protocol TasksInteractorInput: class {

    func reloadTasks (inDay day: Day)
    func reloadTasks (inMonth date: Date)
}

protocol TasksInteractorOutput: class {

    func tasksDidLoad (_ tasks: [Task])
}

class TasksInteractor {

    weak var presenter: TasksInteractorOutput?

    private let tasksReader: ReadTasksInteractor!
    private let moduleGit = ModuleGitLogs()
    private let moduleCalendar = ModuleCalendar()
    private let pref = RCPreferences<LocalPreferences>()
    private var currentTasks = [Task]()
    private var currentDateStart: Date?

    init() {
        tasksReader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
    }
}

extension TasksInteractor: TasksInteractorInput {

    func reloadTasks (inDay day: Day) {

        let dateStart = day.dateStart
        let dateEnd = day.dateEnd ?? dateStart.endOfDay()
        currentDateStart = dateStart
        reloadTasks(dateStart: dateStart, dateEnd: dateEnd)
    }

    func reloadTasks (inMonth date: Date) {

        let dateStart = date.startOfMonth()
        let dateEnd = date.endOfMonth()
        currentDateStart = dateStart
        reloadTasks(dateStart: dateStart, dateEnd: dateEnd)
    }

    private func reloadTasks (dateStart: Date, dateEnd: Date) {

        self.currentTasks = []
        self.addLocalTasks(dateStart: dateStart, dateEnd: dateEnd) { [weak self] in
            guard let self, !self.currentTasks.isEmpty else {
                self?.presenter?.tasksDidLoad([])
                return
            }
            let isMonthRead = dateEnd.timeIntervalSince(dateStart) > 24.hoursToSec
            if isMonthRead || self.currentTasks.contains(where: { $0.taskType == .endDay }) {
                self.presenter?.tasksDidLoad(self.currentTasks)
                return
            }
            self.addGitLogs(dateStart: dateStart, dateEnd: dateEnd) { [weak self] in
                self?.addCalendarEvents(dateStart: dateStart, dateEnd: dateEnd) { [weak self] in
                    guard let self else {
                        return
                    }
                    self.presenter?.tasksDidLoad(self.currentTasks)
                }
            }
        }
    }

    private func addLocalTasks (dateStart: Date, dateEnd: Date, completion: () -> Void) {
        currentTasks = tasksReader.tasks(between: dateStart, and: dateEnd)
        // Sort by date
        currentTasks.sort(by: {
            // If tasks have the same date might be the end of the day compared with the last task
            // In this case endDay should be the latter task
            guard $0.endDate != $1.endDate else {
                return $1.taskType == .endDay
            }
            return $0.endDate < $1.endDate
        })
        completion()
    }

    private func addGitLogs (dateStart: Date, dateEnd: Date, completion: @escaping () -> Void) {

        guard pref.bool(.enableGit) else {
            completion()
            return
        }
        moduleGit.fetchLogs(dateStart: dateStart, dateEnd: dateEnd) { [weak self] gitTasks in

            guard let self, self.currentDateStart == dateStart else {
                RCLog("Different day was selected than the one loading")
                return
            }
            self.currentTasks = MergeTasksInteractor().merge(tasks: self.currentTasks, with: gitTasks)
            completion()
        }
    }

    private func addCalendarEvents (dateStart: Date, dateEnd: Date, completion: @escaping () -> Void) {

        guard pref.bool(.enableCalendar) else {
            completion()
            return
        }
        moduleCalendar.events(dateStart: dateStart, dateEnd: dateEnd) { [weak self] (calendarTasks) in

            guard let self, self.currentDateStart == dateStart else {
                RCLog("Different day was selected than the one loading")
                return
            }
            self.currentTasks = MergeTasksInteractor().merge(tasks: self.currentTasks, with: calendarTasks)
            completion()
        }
    }
}

//
//  TasksPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol TasksPresenterInput: class {
    
    func initUI()
    func syncData()
    func reloadData()
    func reloadTasksOnDay (_ day: Day, listType: ListType)
    func updateNoTasksState()
    func messageButtonDidPress()
    func startDay()
    func endDay()
    func insertTaskWithData (_ taskData: TaskCreationData)
    func insertTaskAfterRow (_ row: Int)
    func removeTaskAtRow (_ row: Int)
}

protocol TasksPresenterOutput: class {
    
    func showLoadingIndicator (_ show: Bool)
    func showMessage (_ message: MessageViewModel)
    func showDates (_ weeks: [Week])
    func showTasks (_ tasks: [Task])
    func showReports (_ reports: [Report])
    func selectDay (_ day: Day)
    func presentNewTaskController (withInitialDate date: Date)
    func presentEndDayController (date: Date, tasks: [Task])
}

enum ListType: Int {
    
    case allTasks = 0
    case report = 1
}

class TasksPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: TasksPresenterOutput?
    
    private var currentTasks = [Task]()
    private var currentReports = [Report]()
    private var selectedListType = ListType.allTasks
    private let pref = RCPreferences<LocalPreferences>()
    private var lastSelectedDay: Day?
    private var interactor: ReadDaysInteractor?
    private let moduleGit = ModuleGitLogs()
    private let moduleCalendar = ModuleCalendar()
    private let reportInteractor = CreateReport()
}

extension TasksPresenter: TasksPresenterInput {
    
    func initUI() {
        reloadData()
        ui!.showLoadingIndicator(false)
//        updateNoTasksState()
    }
    
    func syncData() {
        reloadData()
    }
    
    func reloadData() {
        
        ui!.showLoadingIndicator(true)
        
        let todayDay = Day(dateStart: Date(), dateEnd: nil)
        interactor = ReadDaysInteractor(repository: localRepository, remoteRepository: remoteRepository)
        interactor?.query(startingDate: Date(timeIntervalSinceNow: -2.monthsToSec).startOfDay()) { [weak self] weeks in
            DispatchQueue.main.async {
                guard let wself = self, let ui = wself.ui else {
                    return
                }
                ui.showLoadingIndicator(false)
                ui.showDates(weeks)
                ui.selectDay(todayDay)
                wself.reloadTasksOnDay(todayDay, listType: wself.selectedListType)
            }
        }
    }
    
    func reloadTasksOnDay (_ day: Day, listType: ListType) {

        lastSelectedDay = day
        selectedListType = listType
        
        ui!.showLoadingIndicator(true)
        
        self.fetchLocalTasks(day) {
            guard !self.currentTasks.isEmpty else {
                self.displayTasks (self.currentTasks)
                self.ui!.showLoadingIndicator(false)
                return
            }
            self.fetchGitLogs(day) {
                self.fetchCalendarEvents(day) {
                    self.displayTasks (self.currentTasks)
                    self.ui!.showLoadingIndicator(false)
                }
            }
        }
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
    
    private func displayTasks (_ tasks: [Task]) {
        
        switch selectedListType {
        case .report:
            let settings = SettingsInteractor().getAppSettings()
            let targetHoursInDay = pref.bool(.enableRoundingDay)
                ? TimeInteractor(settings: settings).workingDayLength()
                : nil
            let reports = reportInteractor.reports(fromTasks: currentTasks, targetHoursInDay: targetHoursInDay)
            currentReports = reports.reversed()
            ui!.showReports(currentReports)
        case .allTasks:
            ui!.showTasks(currentTasks)
        }
        updateNoTasksState()
    }
    
    func updateNoTasksState() {
        
        if currentTasks.count == 0 {
            ui!.showMessage((
                title: "Good morning!",
                message: "Ready to begin your working day?",
                buttonTitle: "Start day"))
        }
        else if currentTasks.count == 1, selectedListType == .report {
            ui!.showMessage((
                title: "No task yet",
                message: "Go to 'All tasks' tab and log some work first!",
                buttonTitle: nil))
        } else {
            appWireframe!.removePlaceholder()
        }
    }
    
    func messageButtonDidPress() {
        
        if currentTasks.count == 0 {
            startDay()
        } else {
            ui!.presentNewTaskController(withInitialDate: Date())
        }
    }
    
    func startDay() {
        
        let now = Date()
        let task = Task(endDate: now, type: TaskType.startDay)
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(task, allowSyncing: true, completion: { [weak self] savedTask in
            self?.reloadData()
        })
        ModuleHookup().insert(task: task)
    }

    func endDay() {
        ui!.presentEndDayController(date: lastSelectedDay?.dateStart ?? Date(), tasks: currentTasks)
    }

    func insertTaskWithData (_ taskData: TaskCreationData) {
        
        var task = Task(subtype: TaskSubtype.issueEnd)
        task.notes = taskData.notes
        task.taskNumber = taskData.taskNumber
        task.startDate = taskData.dateStart
        task.endDate = taskData.dateEnd
        task.taskType = taskData.taskType
        
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(task, allowSyncing: false, completion: { savedTask in
            
        })
    }
    
    func insertTaskAfterRow (_ row: Int) {
        
        guard currentTasks.count > row + 1 else {
            let taskBefore = currentTasks[row]
            let nextDate = taskBefore.endDate.isSameDayAs(Date()) ? Date() : taskBefore.endDate.addingTimeInterval(3600)
            ui!.presentNewTaskController(withInitialDate: nextDate)
            return
        }
        let taskBefore = currentTasks[row]
        let taskAfter = currentTasks[row+1]
        let middleTimestamp = taskAfter.endDate.timeIntervalSince(taskBefore.endDate) / 2
        let middleDate = taskBefore.endDate.addingTimeInterval(middleTimestamp)
        ui!.presentNewTaskController(withInitialDate: middleDate)
    }
    
    func removeTaskAtRow (_ row: Int) {
        
        let task = currentTasks[row]
        currentTasks.remove(at: row)
        let deleteInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        deleteInteractor.deleteTask(task)
        updateNoTasksState()
        if currentTasks.count == 0 {
            let reader = ReadDaysInteractor(repository: localRepository, remoteRepository: remoteRepository)
            ui?.showDates(reader.weeks())
        }
    }
}

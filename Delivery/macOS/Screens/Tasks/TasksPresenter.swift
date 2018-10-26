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
    func showCalendar (_ weeks: [Week])
    func showTasks (_ tasks: [Task])
    func showReports (_ reports: [Report], numberOfDays: Int, type: ListType)
    func selectDay (_ day: Day)
    func presentNewTaskController (withInitialDate date: Date)
    func presentEndDayController (date: Date, tasks: [Task])
}

class TasksPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: TasksPresenterOutput?
    var interactor: TasksInteractorInput?
    
    private var currentTasks = [Task]()
    private var currentReports = [Report]()
    private var selectedListType = ListType.allTasks
    private let pref = RCPreferences<LocalPreferences>()
    private var lastSelectedDay: Day?
}

extension TasksPresenter: TasksPresenterInput {
    
    func initUI() {
        ui!.showLoadingIndicator(false)
        reloadData()
//        updateNoTasksState()
    }
    
    func syncData() {
        reloadData()
    }
    
    func reloadData() {
        ui!.showLoadingIndicator(true)
        interactor!.reloadCalendar()
    }

    func reloadTasksOnDay (_ day: Day, listType: ListType) {
        ui!.showLoadingIndicator(true)
        lastSelectedDay = day
        selectedListType = listType
        switch selectedListType {
        case .allTasks, .report:
            interactor?.reloadTasks(inDay: day)
        case .monthlyReports:
            interactor?.reloadTasks(inMonth: day)
        }
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
            ui?.showCalendar(reader.weeks())
        }
    }
}

extension TasksPresenter: TasksInteractorOutput {

    func calendarDidLoad (_ weeks: [Week]) {

        guard let ui = self.ui else {
            return
        }
        ui.showLoadingIndicator(false)
        let todayDay = Day(dateStart: Date(), dateEnd: nil)
        ui.showCalendar(weeks)
        ui.selectDay(todayDay)
    }

    func tasksDidLoad (_ tasks: [Task]) {

        guard let ui = self.ui else {
            return
        }
        ui.showLoadingIndicator(false)
        currentTasks = tasks

        switch selectedListType {
        case .allTasks:
            ui.showTasks(currentTasks)
        case .report:
            let settings = SettingsInteractor().getAppSettings()
            let targetHoursInDay = pref.bool(.enableRoundingDay)
                ? TimeInteractor(settings: settings).workingDayLength()
                : nil
            let reportInteractor = CreateReport()
            let reports = reportInteractor.reports(fromTasks: currentTasks, targetHoursInDay: targetHoursInDay)
            currentReports = reports.reversed()
            ui.showReports(currentReports, numberOfDays: 1, type: selectedListType)
        case .monthlyReports:
            let settings = SettingsInteractor().getAppSettings()
            let targetHoursInDay = pref.bool(.enableRoundingDay)
                ? TimeInteractor(settings: settings).workingDayLength()
                : nil
            let reportInteractor = CreateMonthReport()
            let reports = reportInteractor.reports(fromTasks: currentTasks, targetHoursInDay: targetHoursInDay)
            currentReports = reports.byTasks
            ui.showReports(currentReports, numberOfDays: reports.byDays.count, type: selectedListType)
            break
        }
        updateNoTasksState()
    }
}

//
//  TasksPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Cocoa

protocol TasksPresenterInput: class {
    
    func initUI()
    func syncData()
    func reloadData()
    func reloadTasksOnDay (_ day: Day, listType: ListType)
    func updateNoTasksState()
    func messageButtonDidPress()
    func startDay()
    func closeDay (shouldSaveToJira: Bool)
    func insertTaskWithData (_ taskData: TaskCreationData)
    func insertTask (after row: Int)
    func removeTask (at row: Int)
}

protocol TasksPresenterOutput: class {
    
    func showLoadingIndicator (_ show: Bool)
    func showWarning (_ show: Bool)
    func showMessage (_ message: MessageViewModel)
    func showCalendar (_ weeks: [Week])
    func showTasks (_ tasks: [Task])
    func showReports (_ reports: [Report], numberOfDays: Int, type: ListType)
    func removeTasksController()
    func selectDay (_ day: Day)
    func presentNewTaskController (date: Date)
    func presentEndDayController (date: Date, tasks: [Task])
}

enum ListType: Int {
    
    case allTasks = 0
    case report = 1
    case monthlyReports = 2
}

class TasksPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: TasksPresenterOutput?
    var interactor: TasksInteractorInput?
    
    private var currentTasks = [Task]()
    private var currentReports = [Report]()
    private var selectedListType = ListType.allTasks
    private let pref = RCPreferences<LocalPreferences>()
    private var extensions = ExtensionsInteractor()
    private var lastSelectedDay: Day?
}

extension TasksPresenter: TasksPresenterInput {
    
    func initUI() {
        ui!.showWarning(false)
        ui!.showLoadingIndicator(false)
        reloadData()
        extensions.getVersions { [weak self] (versions) in
            guard let userInterface = self?.ui else {
                return
            }
            let compatibility = Versioning(versions: versions)
            if compatibility.shellScript.available {
                userInterface.showWarning(!compatibility.jirassic.compatible || !compatibility.jit.compatible)
            } else {
                userInterface.showWarning(false)
            }
        }
//        updateNoTasksState()
    }
    
    func syncData() {
        reloadData()
    }
    
    func reloadData() {
        ui!.removeTasksController()
        ui!.showLoadingIndicator(true)
        interactor!.reloadCalendar()
    }

    func reloadTasksOnDay (_ day: Day, listType: ListType) {
        ui!.removeTasksController()
        ui!.showLoadingIndicator(true)
        lastSelectedDay = day
        selectedListType = listType
        switch selectedListType {
        case .allTasks, .report:
            interactor!.reloadTasks(inDay: day)
        case .monthlyReports:
            interactor!.reloadTasks(inMonth: day)
        }
    }

    func updateNoTasksState() {
        
        if currentTasks.count == 0 {
            ui!.showMessage((
                title: "Good morning!",
                message: "Ready to start working today?",
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
            ui!.presentNewTaskController(date: Date())
        }
    }
    
    func startDay() {
        
        let task = Task(endDate: Date(), type: .startDay)
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(task, allowSyncing: true, completion: { [weak self] savedTask in
            self?.reloadData()
        })
        ModuleHookup().insert(task: task)
    }

    func closeDay (shouldSaveToJira: Bool) {
        
        let closeDay = CloseDay()
        closeDay.close(with: currentTasks)
        if shouldSaveToJira {
            // Reload data will be called after save with success
            ui!.presentEndDayController(date: lastSelectedDay?.dateStart ?? Date(), tasks: currentTasks)
        } else {
            reloadData()
        }
    }

    func insertTaskWithData (_ taskData: TaskCreationData) {
        
        var task = Task()
        task.notes = taskData.notes
        task.taskNumber = taskData.taskNumber
        task.startDate = taskData.dateStart
        task.endDate = taskData.dateEnd
        task.taskType = taskData.taskType
        
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(task, allowSyncing: false, completion: { savedTask in
            
        })
    }
    
    func insertTask (after row: Int) {
        
        guard currentTasks.count > row + 1 else {
            // Insert task at the end
            let taskBefore = currentTasks[row]
            let nextDate = taskBefore.endDate.isSameDayAs(Date()) ? Date() : taskBefore.endDate.addingTimeInterval(3600)
            ui!.presentNewTaskController(date: nextDate)
            return
        }
        // Insert task between 2 other tasks
        let taskBefore = currentTasks[row]
        let taskAfter = currentTasks[row+1]
        let middleTimestamp = taskAfter.endDate.timeIntervalSince(taskBefore.endDate) / 2
        let middleDate = taskBefore.endDate.addingTimeInterval(middleTimestamp)
        ui!.presentNewTaskController(date: middleDate)
    }
    
    func removeTask (at row: Int) {
        
        let task = currentTasks[row]
        currentTasks.remove(at: row)
        let deleteInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        deleteInteractor.deleteTask(task)
        updateNoTasksState()
        if currentTasks.count == 0 {
            let reader = ReadDaysInteractor(repository: localRepository, remoteRepository: nil)
            reader.queryAll { [weak self] (weeks) in
                self?.ui?.showCalendar(weeks)
            }
        }
    }
}

extension TasksPresenter: TasksInteractorOutput {

    func calendarDidLoad (_ weeks: [Week]) {

        guard let ui = self.ui else {
            return
        }
        ui.showLoadingIndicator(false)
        let day = lastSelectedDay ?? Day(dateStart: Date(), dateEnd: nil)
        ui.showCalendar(weeks)
        ui.selectDay(day)
    }

    func tasksDidLoad (_ tasks: [Task]) {

        guard let ui = self.ui else {
            return
        }
        ui.showLoadingIndicator(false)
        ui.removeTasksController()
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
            let reports = reportInteractor.reports(fromTasks: currentTasks, targetHoursInDay: targetHoursInDay, roundHours: true)
            currentReports = reports.byTasks
            ui.showReports(currentReports, numberOfDays: reports.byDays.count, type: selectedListType)
            break
        }
        updateNoTasksState()
    }
}

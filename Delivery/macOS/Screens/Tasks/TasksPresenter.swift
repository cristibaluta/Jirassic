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
    weak var userInterface: TasksPresenterOutput?
    fileprivate var currentTasks = [Task]()
    fileprivate var currentReports = [Report]()
    fileprivate var selectedListType = ListType.allTasks
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    fileprivate var lastSelectedDay: Day?
    fileprivate var interactor: ReadDaysInteractor?
    fileprivate let moduleGit = ModuleGitLogs()
}

extension TasksPresenter: TasksPresenterInput {
    
    func initUI() {
        reloadData()
        userInterface!.showLoadingIndicator(false)
//        updateNoTasksState()
    }
    
    func syncData() {
        reloadData()
    }
    
    func reloadData() {
        
        userInterface!.showLoadingIndicator(true)
        
        let todayDay = Day(dateStart: Date(), dateEnd: nil)
        interactor = ReadDaysInteractor(repository: localRepository, remoteRepository: remoteRepository)
        interactor?.query { [weak self] weeks in
            DispatchQueue.main.async {
                guard let wself = self, let userInterface = wself.userInterface else {
                    return
                }
                userInterface.showLoadingIndicator(false)
                userInterface.showDates(weeks)
                userInterface.selectDay(todayDay)
                wself.reloadTasksOnDay(todayDay, listType: wself.selectedListType)
            }
        }
    }
    
    func reloadTasksOnDay (_ day: Day, listType: ListType) {

        lastSelectedDay = day
        let settings = SettingsInteractor().getAppSettings()
        let targetHoursInDay = localPreferences.bool(.enableRoundingDay) 
            ? TimeInteractor(settings: settings).workingDayLength()
            : nil
        let reader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
        let localTasks = reader.tasksInDay(day.dateStart)
        selectedListType = listType
        
        guard localPreferences.bool(.enableGit) else {
            updateNoTasksState()
            return
        }
        userInterface!.showLoadingIndicator(true)
        
        moduleGit.logs(onDate: day.dateStart) { [weak self] gitTasks in
            
            guard let wself = self, let userInterface = wself.userInterface else {
                return
            }
            wself.currentTasks = MergeTasksInteractor().merge(tasks: localTasks, with: gitTasks)
            
            if listType == .report {
                let reportInteractor = CreateReport()
                let reports = reportInteractor.reports(fromTasks: wself.currentTasks, targetHoursInDay: targetHoursInDay)
                wself.currentReports = reports.reversed()
                userInterface.showReports(wself.currentReports)
            }
            else {
                userInterface.showTasks(wself.currentTasks)
            }
            
            wself.updateNoTasksState()
            userInterface.showLoadingIndicator(false)
        }
    }
    
    func updateNoTasksState() {
        
        if currentTasks.count == 0 {
            userInterface!.showMessage((
                title: "Good morning!",
                message: "Ready to begin your working day?",
                buttonTitle: "Start day"))
        }
        else if currentTasks.count == 1, selectedListType == .report {
            userInterface!.showMessage((
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
            userInterface!.presentNewTaskController(withInitialDate: Date())
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
        userInterface!.presentEndDayController(date: lastSelectedDay?.dateStart ?? Date(), tasks: currentTasks)
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
            userInterface!.presentNewTaskController(withInitialDate: Date())
            return
        }
        let taskBefore = currentTasks[row]
        let taskAfter = currentTasks[row+1]
        let middleTimestamp = taskAfter.endDate.timeIntervalSince(taskBefore.endDate) / 2
        let middleDate = taskBefore.endDate.addingTimeInterval(middleTimestamp)
        userInterface!.presentNewTaskController(withInitialDate: middleDate)
    }
    
    func removeTaskAtRow (_ row: Int) {
        
        let task = currentTasks[row]
        currentTasks.remove(at: row)
        let deleteInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        deleteInteractor.deleteTask(task)
        updateNoTasksState()
        if currentTasks.count == 0 {
            let reader = ReadDaysInteractor(repository: localRepository, remoteRepository: remoteRepository)
            userInterface?.showDates(reader.weeks())
        }
    }
}

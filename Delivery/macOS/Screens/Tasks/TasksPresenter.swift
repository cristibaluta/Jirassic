//
//  TasksPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Cocoa
import RCLog

protocol TasksPresenterInput: class {
    
    func reloadLastSelectedDay()
    func reloadTasksOnDay (_ day: Day)
    func updateNoTasksState()
    func closeDay (showWorklogs: Bool)
    func insertTaskWithData (_ taskData: TaskCreationData)
    func updateTask (_ task: Task, with taskData: TaskCreationData)
    func insertTask (after row: Int)
    func removeTask (at row: Int)
    func editTask (at row: Int)
    func didClickStartDay()
    func didClickSaveWorklogs()
}

protocol TasksPresenterOutput: class {
    
    func showLoadingIndicator (_ show: Bool)
    func showMessage (_ message: MessageViewModel)
    func showTasks (_ tasks: [Task])
    func presentNewTaskController (date: Date)
    func presentTaskEditor(task: Task)
    func closeTaskEditor()
    func showWorklogs (date: Date, tasks: [Task])
    func removeTasks()
    func removeWorklogs()
}

class TasksPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: TasksPresenterOutput?
    var interactor: TasksInteractorInput?
    
    private var currentTasks = [Task]()
    private var lastSelectedDay: Day = Day(dateStart: Date(), dateEnd: nil)
}

extension TasksPresenter: TasksPresenterInput {
    
    func reloadLastSelectedDay() {
        reloadTasksOnDay(lastSelectedDay)
    }
    
    func reloadTasksOnDay (_ day: Day) {
        lastSelectedDay = day
        ui!.removeTasks()
        ui!.removeWorklogs()
        ui!.showLoadingIndicator(true)
        interactor!.reloadTasks(inDay: day)
    }

    func updateNoTasksState() {
        
        if currentTasks.count == 0 {
            if lastSelectedDay.dateStart.isToday() {
                ui!.showMessage((
                    title: "Good morning!",
                    message: "Ready to start working today?",
                    buttonTitle: "Start day"))
            } else {
                ui!.showMessage((
                title: "Day was not started!",
                message: "Do you want to start it now?",
                buttonTitle: "Start day"))
            }
        } else {
            appWireframe!.removePlaceholder()
        }
    }
    
    func didClickStartDay() {
        
        if currentTasks.count == 0 {
            startDay()
        } else {
            ui!.presentNewTaskController(date: Date())
        }
    }
    
    func startDay() {
        
        /// The day will start
        /// 1. current timestamp if day is today
        /// 2. start  timestamp from settings if day is not today
        let settings: Settings = SettingsInteractor().getAppSettings()
        let startDate = lastSelectedDay.dateStart.isToday()
            ? Date()
            : lastSelectedDay.dateStart.dateByKeepingTime(from: settings.settingsTracking.startOfDayTime)
        let task = Task(endDate: startDate, type: .startDay)
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(task, allowSyncing: true, completion: { [weak self] savedTask in
            self?.reloadLastSelectedDay()
        })
        ModuleHookup().insert(task: task)
    }
    
    func closeDay (showWorklogs: Bool) {
        
        let closeDay = CloseDayInteractor()
        closeDay.close(with: currentTasks)
        
        if showWorklogs {
            didClickSaveWorklogs()
        } else {
            reloadLastSelectedDay()
        }
    }
    
    func didClickSaveWorklogs() {
        // Reload data will be called after save with success
        ui!.removeTasks()
        ui!.showWorklogs(date: lastSelectedDay.dateStart, tasks: currentTasks)
    }

    func insertTaskWithData (_ taskData: TaskCreationData) {
        updateTask(Task(), with: taskData)
    }

    func updateTask (_ task: Task, with taskData: TaskCreationData) {

        var task = task
        task.notes = taskData.notes
        task.taskNumber = taskData.taskNumber
        task.startDate = taskData.dateStart
        task.endDate = taskData.dateEnd
        task.taskType = taskData.taskType

        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(task, allowSyncing: false, completion: { _ in })
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
            
        }
    }

    func editTask (at row: Int) {
        let task = currentTasks[row]
        RCLog("Star tediting task: \(task)")
        ui!.closeTaskEditor()// Close current task editor if exists
        ui!.presentTaskEditor(task: task)
    }
}

extension TasksPresenter: TasksInteractorOutput {

    func tasksDidLoad (_ tasks: [Task]) {
        RCLog(tasks)
        guard let ui = self.ui else {
            return
        }
        ui.showLoadingIndicator(false)
        currentTasks = tasks
        ui.removeTasks()
        ui.showTasks(currentTasks)
        updateNoTasksState()
    }
}

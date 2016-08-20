//
//  TasksPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

protocol TasksPresenterInput {
    
    func refreshUI()
    func reloadData()
    func reloadTasksOnDay (day: Day, listType: ListType)
    func updateNoTasksState()
    func messageButtonDidPress()
    func startDay()
    func insertTaskWithData (taskData: TaskCreationData)
    func insertTaskAfterRow (row: Int)
    func removeTaskAtRow (row: Int)
}

protocol TasksPresenterOutput {
    
    func showLoadingIndicator (show: Bool)
    func showMessage (message: MessageViewModel)
    func showDates (weeks: [Week])
    func showTasks (tasks: [Task])
    func selectDay (day: Day)
    func presentNewTaskController()
}

enum ListType: Int {
    
    case AllTasks = 0
    case Report = 1
}

class TasksPresenter {
    
    var appWireframe: AppWireframe?
    var userInterface: TasksPresenterOutput?
    private var day: NewDay?
    private var currentTasks = [Task]()
    private var selectedListType = ListType.AllTasks
    
}

extension TasksPresenter: TasksPresenterInput {
    
    func refreshUI() {
        
        // Prevent reloading data when you open the popover for the second time in the same day
        if day == nil || day!.isNewDay() {
            reloadData()
        }
        updateNoTasksState()
    }
    
    func reloadData() {
        
        let todayDay = Day(date: NSDate())
        let reader = ReadDaysInteractor(data: localRepository)
        userInterface?.showDates(reader.weeks())
        userInterface?.selectDay(todayDay)
        reloadTasksOnDay(todayDay, listType: selectedListType)
    }
    
    func reloadTasksOnDay (day: Day, listType: ListType) {
        
        let reader = ReadTasksInteractor(data: localRepository)
        currentTasks = reader.tasksInDay(day.date).reverse()
        
        if listType == .Report {
            let report = CreateReport(tasks: currentTasks)
            report.round()
            currentTasks = report.tasks.reverse()
        }
        
        userInterface?.showTasks(currentTasks)
        
        updateNoTasksState()
    }
    
    func updateNoTasksState() {
        
        if currentTasks.count <= 1 {
            if currentTasks.count == 0 {
                userInterface?.showMessage((
                    title: "Good morning!",
                    message: "Ready to begin your working day?",
                    buttonTitle: "Start day"))
            } else {
                userInterface?.showMessage((
                    title: "No task yet.",
                    message: "When you're ready with your first task click \n'+' or 'Log time'",
                    buttonTitle: "Log time"))
            }
        } else {
            appWireframe?.removeMessage()
        }
    }
    
    func messageButtonDidPress() {
        
        if currentTasks.count == 0 {
            startDay()
        } else {
            userInterface?.presentNewTaskController()
        }
    }
    
    func startDay() {
        
        let now = NSDate()
        let task = Task(dateEnd: now, type: TaskType.StartDay)
        let saveInteractor = TaskInteractor(data: localRepository)
        saveInteractor.saveTask(task)
        day?.setLastTrackedDay(now)
        reloadData()
    }
    
    func insertTaskWithData (taskData: TaskCreationData) {
        
        var task = Task(subtype: TaskSubtype.IssueEnd)
        task.notes = taskData.notes
        task.taskNumber = taskData.taskNumber
        task.endDate = taskData.dateEnd
        
        let saveInteractor = TaskInteractor(data: localRepository)
            saveInteractor.saveTask(task)
    }
    
    func insertTaskAfterRow (row: Int) {
        userInterface?.presentNewTaskController()
    }
    
    func removeTaskAtRow (row: Int) {
        
        let task = currentTasks[row]
        let deleteInteractor = TaskInteractor(data: localRepository)
        deleteInteractor.deleteTask(task)
    }
}

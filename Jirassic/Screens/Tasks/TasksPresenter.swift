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
    func reloadDataFromServer()
    func reloadTasksOnDay (date: NSDate)
    func updateNoTasksState()
    func createReport()
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
    func setSelectedDay (date: String)
    func presentNewTaskController()
}

class TasksPresenter {
    
    var appWireframe: AppWireframe?
    var userInterface: TasksPresenterOutput?
    private var day: NewDay?
    private var currentTasks = [Task]()
    
}

extension TasksPresenter: TasksPresenterInput {
    
    func refreshUI() {
        
        // Prevent reloading data when you open the popover for the second time in the same day
        if day == nil || day!.isNewDay() {
            reloadDataFromServer()
        }
        updateNoTasksState()
    }
    
    func reloadData() {
        let reader = ReadDaysInteractor(data: localRepository)
        userInterface?.showDates(reader.weeks())
        reloadTasksOnDay(NSDate())
    }
    
    func reloadTasksOnDay (date: NSDate) {
        
        let reader = ReadTasksInteractor(data: localRepository)
        currentTasks = reader.tasksInDay(date).reverse()
        userInterface?.showTasks(currentTasks)
        userInterface?.setSelectedDay(date.EEEEMMdd())
        
        updateNoTasksState()
    }
    
    func reloadDataFromServer() {
        
        reloadData()
//        userInterface?.showLoadingIndicator(true)
//        
//        ReadTasksInteractor(data: localRepository).tasksAtPage(0, completion: { [weak self] (tasks) -> Void in
//            
//            self?.currentTasks = tasks
//            self?.userInterface?.showTasks(tasks)
//            self?.userInterface?.showLoadingIndicator(false)
//            
//            reloadTasksOnDay(NSDate())
//        })
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
    
    func createReport() {
        
        let reader = ReadTasksInteractor(data: localRepository)
        let report = CreateReport(tasks: reader.tasksInDay(NSDate()).reverse())
        report.round()
        userInterface?.showTasks(report.tasks.reverse())
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
        task.issueType = taskData.issueType
        task.issueId = taskData.issueId
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

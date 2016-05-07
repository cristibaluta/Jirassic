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
}

protocol TasksPresenterOutput {
    
    func showLoadingIndicator (show: Bool)
    func showMessage (message: MessageViewModel)
    func showDates (weeks: [Week])
    func showTasks (tasks: [Task])
    func setSelectedDay (date: String)
}

class TasksPresenter {
    
    var appWireframe: AppWireframe?
    var userInterface: TasksPresenterOutput?
    private var day = NewDay()
    
}

extension TasksPresenter: TasksPresenterInput {
    
    func refreshUI() {
        
        updateNoTasksState()
        reloadDataFromServer()
        if day.isNewDay() {
            reloadData()
        }
    }
    
    func reloadData() {
        self.reloadTasksOnDay(NSDate())
    }
    
    func reloadTasksOnDay (date: NSDate) {
        
        let reader = ReadTasksInteractor(data: localRepository)
        userInterface?.showTasks(reader.tasksInDay(date))
        userInterface?.setSelectedDay(date.EEEEMMdd())
        
        updateNoTasksState()
    }
    
    func reloadDataFromServer() {
        
        userInterface?.showLoadingIndicator(true)
        
        ReadTasksInteractor(data: localRepository).tasksAtPage(0, completion: { [weak self] (tasks) -> Void in
            
            self?.userInterface?.showTasks(tasks)
            self?.userInterface?.showLoadingIndicator(false)
            
            let reader = ReadDaysInteractor(data: localRepository)
            self?.userInterface?.showDates(reader.weeks())
        })
    }
    
    func updateNoTasksState() {
        
        userInterface?.showMessage((title: nil, message: "Good morning! Ready for your first task?", buttonTitle: "Start day!"))
        //        if appWireframe?.tasksScrollView.data.count == 0 {
        //            messageViewController.viewModel =
        //            appWireframe?.presentNoTaskController(messageViewController, overController: self, splitView: splitView!)
        //        }
        //        else if tasksScrollView!.data.count == 1 {
        //            messageViewController.viewModel = (title: nil, message: "When you finish tasks press +\nTime will be calculated for you automatically", buttonTitle: nil)
        //            appWireframe?.presentNoTaskController(messageViewController, overController: self, splitView: splitView!)
        //        }
        //        else {
        //            removeNoTasksController()
        //        }
    }
    
    func createReport() {
        
        let reader = ReadTasksInteractor(data: localRepository)
        let report = CreateReport(tasks: reader.tasksInDay(NSDate()).reverse())
        report.round()
        userInterface?.showTasks(report.tasks.reverse())
    }
}

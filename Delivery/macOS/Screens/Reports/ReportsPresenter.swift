//
//  ReportsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 27/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa
import RCPreferences

protocol ReportsPresenterInput: class {
    
    func viewDidLoad()
    func reloadData()
    func reloadReportsOnDay (_ day: Day)
    func reloadReportsInMonth (_ date: Date)
    func updateNoTasksState()
}

protocol ReportsPresenterOutput: class {
    
    func showLoadingIndicator (_ show: Bool)
    func showMessage (_ message: MessageViewModel)
    func showReports (_ reports: [Report], numberOfDays: Int, type: ListType)
}

class ReportsPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: ReportsPresenterOutput?
    var interactor: ReportsInteractorInput?
    
    private var currentTasks = [Task]()
    private var currentReports = [Report]()
    private let pref = RCPreferences<LocalPreferences>()
    private var extensions = ExtensionsInteractor()
    private var lastSelectedDay: Day?
}

extension ReportsPresenter: ReportsPresenterInput {
    
    func viewDidLoad() {
        ui!.showLoadingIndicator(true)
        reloadData()
    }
    
    func reloadData() {
        ui!.showLoadingIndicator(true)
    }
    
    func reloadReportsOnDay (_ day: Day) {
        
    }
    
    func reloadReportsInMonth (_ date: Date) {
    
    }

    func reloadTasksOnDay (_ day: Day, listType: ListType) {
        ui!.showLoadingIndicator(true)
        lastSelectedDay = day
        interactor!.reloadTasks(inDay: day)
    }

    func updateNoTasksState() {
        
        if currentTasks.count == 1 {
            ui!.showMessage((
                title: "No task yet",
                message: "Go to 'Tasks' tab and log some work first!",
                buttonTitle: nil))
        } else {
            appWireframe!.removePlaceholder()
        }
    }
    
    func messageButtonDidPress() {
        
        if currentTasks.count == 0 {
            startDay()
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
}

extension ReportsPresenter: ReportsInteractorOutput {

    func tasksDidLoad (_ tasks: [Task]) {

        guard let ui = self.ui else {
            return
        }
        ui.showLoadingIndicator(false)
        currentTasks = tasks
        
        let settings = SettingsInteractor().getAppSettings()
        let targetHoursInDay = pref.bool(.enableRoundingDay)
            ? TimeInteractor(settings: settings).workingDayLength()
            : nil
        let reportInteractor = CreateMonthReport()
        let reports = reportInteractor.reports(fromTasks: currentTasks, targetHoursInDay: targetHoursInDay, roundHours: true)
        currentReports = reports.byTasks
//        ui.showReports(currentReports, numberOfDays: reports.byDays.count)

        
//        let settings = SettingsInteractor().getAppSettings()
//        let targetHoursInDay = pref.bool(.enableRoundingDay)
//            ? TimeInteractor(settings: settings).workingDayLength()
//            : nil
//        let reportInteractor = CreateReport()
//        let reports = reportInteractor.reports(fromTasks: currentTasks, targetHoursInDay: targetHoursInDay)
//        currentReports = reports.reversed()
//        ui.showReports(currentReports, numberOfDays: 1, type: selectedListType)
        
        updateNoTasksState()
    }
}

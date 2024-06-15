//
//  ReportsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 27/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa
import RCPreferences
import RCLog

protocol ReportsPresenterInput: class {
    
    func viewDidLoad()
    func reloadLastSelectedMonth()
    func reloadReportsInDay (_ day: Day)
    func reloadReportsInMonth (_ date: Date)
    func copyReportToClipboard(asCsv: Bool)
    func messageButtonDidPress()
}

protocol ReportsPresenterOutput: class {
    
    func showLoadingIndicator (_ show: Bool)
    func showMessage (_ message: MessageViewModel)
    func showReports (_ reports: [Report], numberOfDays: Int)
    func removeReports()
}

class ReportsPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: ReportsPresenterOutput?
    var interactor: TasksInteractorInput?
    
    private var currentTasks = [Task]()
    private var currentReports = [Report]()
    private let pref = RCPreferences<LocalPreferences>()
    private var extensions = ExtensionsInteractor()
    private var lastSelectedDay: Day?
    private var lastSelectedMonth: Date = Date()

    
    private func updateNoTasksState() {
        
        if currentTasks.count == 1 {
            ui!.showMessage((
                title: "No task yet",
                message: "Go to 'Tasks' tab and log some work first!",
                buttonTitle: nil))
        } else {
            appWireframe!.removePlaceholder()
        }
    }

    private func startDay() {

        let task = Task(endDate: Date(), type: .startDay)
        let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
        saveInteractor.saveTask(task, allowSyncing: true, completion: { [weak self] savedTask in
            self?.reloadLastSelectedMonth()
        })
        ModuleHookup().insert(task: task)
    }

    private func copyMonthlyReportsToClipboard(asCsv: Bool) {
        let interactor = CreateMonthReport()
        var string = ""
        if asCsv {
            string = interactor.csvReports(currentReports)
        } else {
            let joined = interactor.joinReports(currentReports)
            string = joined.notes + "\n\n" + joined.totalDuration.secToHoursAndMin
        }
        RCLog(string)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([string as NSPasteboardWriting])
    }

    private func copyDayReportToClipboard() {
        let interactor = CreateDayReport()
        let string = interactor.stringReports(currentReports)
        RCLog(string)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([string as NSPasteboardWriting])
    }
}

extension ReportsPresenter: ReportsPresenterInput {
    
    func viewDidLoad() {
        ui!.showLoadingIndicator(true)
        reloadLastSelectedMonth()
    }
    
    func reloadLastSelectedMonth() {
        reloadReportsInMonth(lastSelectedMonth)
    }
    
    func reloadReportsInDay (_ day: Day) {
        ui!.removeReports()
        ui!.showLoadingIndicator(true)
        lastSelectedDay = day
        interactor!.reloadTasks(inDay: day)
    }
    
    func reloadReportsInMonth (_ date: Date) {
        ui!.removeReports()
        ui!.showLoadingIndicator(true)
        lastSelectedMonth = date
        interactor!.reloadTasks(inMonth: date)
    }
    
    func messageButtonDidPress() {
        
        if currentTasks.count == 0 {
            startDay()
        }
    }

    func copyReportToClipboard(asCsv: Bool) {
        if lastSelectedDay != nil {
            copyDayReportToClipboard()
        } else {
            copyMonthlyReportsToClipboard(asCsv: asCsv)
        }
    }
}

extension ReportsPresenter: TasksInteractorOutput {

    func tasksDidLoad (_ tasks: [Task]) {

        guard let ui else {
            return
        }
        ui.showLoadingIndicator(false)
        currentTasks = tasks
        
        let settings = SettingsInteractor().getAppSettings()
        let targetHoursInDay = pref.bool(.enableRoundingDay)
            ? TimeInteractor(settings: settings).workingDayLength()
            : nil

        if lastSelectedDay != nil {
            let reportInteractor = CreateReport()
            let reports = reportInteractor.reports(fromTasks: currentTasks,
                                                   targetHoursInDay: targetHoursInDay)
            currentReports = reports.reversed()
            ui.removeReports()
            ui.showReports(currentReports, numberOfDays: 1)
        } else {
            let reportInteractor = CreateMonthReport()
            let reports = reportInteractor.reports(fromTasks: currentTasks,
                                                   targetHoursInDay: targetHoursInDay,
                                                   roundHours: true)
            currentReports = reports.byTasks
            ui.removeReports()
            ui.showReports(currentReports, numberOfDays: reports.byDays.count)
        }

        updateNoTasksState()
    }
}

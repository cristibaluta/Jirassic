//
//  EndDayPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

protocol EndDayPresenterInput: class {
    func setup (date: Date, tasks: [Task])
    func save (worklog: String)
    func enableRounding (_ enabled: Bool)
}

protocol EndDayPresenterOutput: class {
    func showRounding (enabled: Bool, title: String)
    func showDuration (_ duration: Double)
    func showWorklog (_ worklog: String)
    func showProgressIndicator (_ show: Bool)
    func showJiraMessage (_ message: String, isError: Bool)
    func saveSuccess()
}

class EndDayPresenter {
    
    weak var userInterface: EndDayPresenterOutput?
    var date: Date?
    private let localPreferences = RCPreferences<LocalPreferences>()
    private var moduleJira = ModuleJiraTempo()
    private var store = Store.shared
    private let reportsInteractor = CreateReport()
    private var workdayLength = 0.0
    private var workedLength = 0.0
    private var tasks: [Task] = []
}

extension EndDayPresenter: EndDayPresenterInput {

    func setup (date: Date, tasks: [Task]) {
        self.date = date
        self.tasks = tasks
        show(tasks: tasks)
    }
    
    private func show (tasks: [Task]) {
        
        // Find the real number of worked hours
        let reports = reportsInteractor.reports(fromTasks: tasks, targetHoursInDay: nil)
        
        let lines = reports.map({ (_ report: Report) -> String in
            let title = self.title(from: report)
            let notes = report.notes.map { (note) -> String in
                return "• \(note)"
            }
            let body = notes.joined(separator: "\n")
            return title + "\n" + body
        })
        let message = lines.joined(separator: "\n\n")
        
        let settings = SettingsInteractor().getAppSettings()
        workdayLength = TimeInteractor(settings: settings).workingDayLength()
        workedLength = StatisticsInteractor().workedTime(fromReports: reports)
        let duration = Date.secondsToPercentTime(localPreferences.bool(.enableRoundingDay) ? workdayLength : workedLength)
        
        userInterface!.showDuration(duration)
        userInterface!.showWorklog(message)
        setupRoundingButton(workdayLength: Date.secondsToPercentTime(workdayLength),
                            workedLength: Date.secondsToPercentTime(workedLength))
    }
    
    private func title (from report: Report) -> String {
        let taskNumber = report.taskNumber
        let taskTitle = report.title
        switch taskNumber {
        case "meeting": return "Meetings:"
        case "coderev": return ""
        default:
            switch taskTitle {
            case "": return taskNumber
            default: return taskNumber + " - " + taskTitle
            }
        }
    }
    
    private func setupRoundingButton (workdayLength: TimeInterval, workedLength: TimeInterval) {
        userInterface!.showRounding(enabled: localPreferences.bool(.enableRoundingDay),
                                    title: "Round worklogs duration to \(String(describing: workdayLength)) hours")
    }
    
    func save (worklog: String) {
        userInterface!.showJiraMessage("", isError: false)

        // Find if the day ended already
        let endDayTask: Task? = self.tasks.filter({$0.taskType == .endDay}).first
        if endDayTask == nil {
            let endDayDate = tasks.last?.endDate ?? Date()
            let endDayTask = Task(endDate: endDayDate, type: .endDay)
            let interactor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
            interactor.saveTask(endDayTask, allowSyncing: true) { (savedTask) in

            }
        }
        
        // Save to jira tempo
        let isJiraEnabled = localPreferences.bool(.enableJira) && store.isJiraTempoPurchased
        let isRoundingEnabled = localPreferences.bool(.enableRoundingDay)
        
        if isJiraEnabled && moduleJira.isReachable {
            userInterface!.showProgressIndicator(true)
            let duration = isRoundingEnabled ? workdayLength : workedLength
            moduleJira.postWorklog(worklog: worklog, duration: duration, date: date!, success: { [weak self] in
                
                DispatchQueue.main.async {
                    if let userInterface = self?.userInterface {
                        userInterface.showProgressIndicator(false)
                        userInterface.showJiraMessage("Worklogs saved to Jira", isError: false)
                        userInterface.saveSuccess()
                    }
                }
            }, failure: { [weak self] error in
                
                DispatchQueue.main.async {
                    if let userInterface = self?.userInterface {
                        userInterface.showProgressIndicator(false)
                        userInterface.showJiraMessage(error.localizedDescription, isError: true)
                    }
                }
            })
        } else {
            userInterface?.saveSuccess()
        }
    }
    
    func enableRounding (_ enabled: Bool) {
        localPreferences.set(enabled, forKey: .enableRoundingDay)
        userInterface!.showDuration(Date.secondsToPercentTime(enabled ? workdayLength : workedLength))
    }
}

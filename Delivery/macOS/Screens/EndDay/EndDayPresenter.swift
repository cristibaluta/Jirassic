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
    func save (jiraTempo: Bool, hookup: Bool, roundTime: Bool, worklog: String)
}

protocol EndDayPresenterOutput: class {
    func showJira (enabled: Bool, available: Bool)
    func showHookup (enabled: Bool, available: Bool)
    func showRounding (enabled: Bool, title: String)
    func showWorklog (_ worklog: String)
    func showProgressIndicator (_ show: Bool)
    func showJiraError (_ error: String)
    func showHookupError (_ error: String)
}

class EndDayPresenter {

    weak var userInterface: EndDayPresenterOutput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    fileprivate var jiraTempoInteractor = ModuleJiraTempo()
    fileprivate var gitModule = ModuleGitLogs()
    fileprivate var hookupModule = ModuleHookup()
    var duration = 0.0
    var date: Date?
    var isJiraAvailable: Bool {
        return localPreferences.string(.settingsJiraUrl) != ""
            && localPreferences.string(.settingsJiraUser) != ""
            && localPreferences.string(.settingsJiraPassword) != ""
            && localPreferences.string(.settingsJiraProjectKey) != ""
            && localPreferences.string(.settingsJiraProjectIssueKey) != ""
    }
}

extension EndDayPresenter: EndDayPresenterInput {

    func setup (date: Date, tasks: [Task]) {
        self.date = date
        show(tasks: tasks)
    }
    
    private func show (tasks: [Task]) {
        
        let settings = SettingsInteractor().getAppSettings()
        let isRoundingEnabled = localPreferences.bool(.enableRoundingDay)
        let targetHoursInDay = isRoundingEnabled
            ? TimeInteractor(settings: settings).workingDayLength()
            : nil
        
        let reportInteractor = CreateReport()
        let reports = reportInteractor.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)
        
        var comment = ""
        for report in reports {
            comment += report.taskNumber + " - " + report.title + "\n" + report.notes + "\n\n"
            duration += report.duration
        }
        let workedHours = Int((targetHoursInDay ?? duration) / 3600)
        
        userInterface!.showWorklog(comment)
        
        // Setup Jira button
        let isJiraEnabled = isJiraAvailable && localPreferences.bool(.enableJira)
        
        userInterface!.showJira(enabled: isJiraEnabled, available: isJiraAvailable)
        
        // Setup Hookup button
        let isHookupAvailable = localPreferences.bool(.enableHookup)
        let isHookupEnabled = isHookupAvailable && localPreferences.bool(.enableJira)
        userInterface!.showHookup(enabled: isHookupEnabled, available: isHookupAvailable && date!.isSameDayAs(Date()))
        
        // Setup round button
        userInterface!.showRounding (enabled: isRoundingEnabled, title: "Round worklog time to \(String(describing: workedHours)) hours")
    }
    
    func save (jiraTempo: Bool, hookup: Bool, roundTime: Bool, worklog: String) {
        
        userInterface!.showJiraError("")
        userInterface!.showHookupError("")
        
        if isJiraAvailable && jiraTempo {
            userInterface!.showProgressIndicator(true)
            jiraTempoInteractor.upload(worklog: worklog, duration: duration, date: date!) { [weak self] success in
                DispatchQueue.main.async {
                    self?.userInterface!.showProgressIndicator(false)
                    if !success {
                        self?.userInterface!.showJiraError("Couldn't save worklog to Jira")
                    }
                }
            }
        }
        
        if hookup && date!.isSameDayAs(Date()) {
            let task = Task(endDate: Date(), type: .endDay)
            hookupModule.insert(task: task) { [weak self] success in
                if !success {
                    self?.userInterface!.showHookupError("Couldn't call hookup")
                }
            }
        }
    }
}

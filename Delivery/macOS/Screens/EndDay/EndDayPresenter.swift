//
//  EndDayPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

protocol EndDayPresenterInput: class {
    func setup (date: Date)
    func save (jiraTempo: Bool, roundTime: Bool, worklog: String)
}

protocol EndDayPresenterOutput: class {
    func showJira (enabled: Bool, available: Bool)
    func showWorklog (_ worklog: String)
    func showRounding (enabled: Bool, title: String)
    func showProgressIndicator (_ show: Bool)
}

class EndDayPresenter {

    weak var userInterface: EndDayPresenterOutput?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()
    fileprivate var jiraTempoInteractor = ModuleJiraTempo()
    fileprivate var hookup = ModuleHookup()
    var duration = 0.0
    var date: Date?
}

extension EndDayPresenter: EndDayPresenterInput {

    func setup (date: Date) {

        //        let now = Date()
        //        let task = Task(dateEnd: now, type: TaskType.endDay)
        //        let saveInteractor = TaskInteractor(repository: localRepository)
        //        saveInteractor.saveTask(task, allowSyncing: true, completion: { savedTask in
        //            //self.reloadData()
        //        })
        self.date = date
        let settings = SettingsInteractor().getAppSettings()
        let isRoundingEnabled = localPreferences.bool(.enableRoundingDay)
        let targetHoursInDay = isRoundingEnabled
            ? TimeInteractor(settings: settings).workingDayLength()
            : nil
        let reader = ReadTasksInteractor(repository: localRepository)
        let tasks = reader.tasksInDay(date)

        let reportInteractor = CreateReport()
        let reports = reportInteractor.reports(fromTasks: tasks, targetHoursInDay: targetHoursInDay)

        var comment = ""
        for report in reports {
            comment += report.taskNumber + " - " + report.title + "\n" + report.notes + "\n\n"
            duration += report.duration
        }

        userInterface!.showWorklog(comment)
        
        // Setup Jira button
        let isJiraAvailable = localPreferences.string(.settingsJiraUrl) != ""
            && localPreferences.string(.settingsJiraUser) != ""
            && localPreferences.string(.settingsJiraPassword) != ""
            && localPreferences.string(.settingsJiraProjectKey) != ""
            && localPreferences.string(.settingsJiraProjectIssueKey) != ""
        let isEnabled = isJiraAvailable && localPreferences.bool(.enableJira)
        
        userInterface!.showJira(enabled: isEnabled, available: isJiraAvailable)
        
        // Setup round button
        userInterface!.showRounding (enabled: isRoundingEnabled, title: "Round worklog time to \(String(describing: targetHoursInDay)) hours")
    }

    func save (jiraTempo: Bool, roundTime: Bool, worklog: String) {

        userInterface!.showProgressIndicator(true)
        jiraTempoInteractor.upload(worklog: worklog, duration: duration, date: date!) { [weak self] success in
            self?.userInterface!.showProgressIndicator(false)
            
        }
    }
}

//
//  WorklogsPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences

protocol WorklogsPresenterInput: class {
    func setup (date: Date, tasks: [Task])
    func save (worklog: String)
    func enableRounding (_ enabled: Bool)
}

protocol WorklogsPresenterOutput: class {
    func showRounding (enabled: Bool, title: String)
    func showDuration (_ duration: Double)
    func showWorklog (_ worklog: String)
    func showProgressIndicator (_ show: Bool)
    func showJiraMessage (_ message: String, isError: Bool)
    func saveSuccess()
}

class WorklogsPresenter {
    
    weak var userInterface: WorklogsPresenterOutput?
    var date: Date?
    private let pref = RCPreferences<LocalPreferences>()
    private var moduleJira = ModuleJiraTempo()
    private let reportsInteractor = CreateReport()
    private var workdayLength = 0.0
    private var workedLength = 0.0
    private var tasks: [Task] = []
}

extension WorklogsPresenter: WorklogsPresenterInput {

    func setup (date: Date, tasks: [Task]) {
        self.date = date
        self.tasks = tasks
        show(tasks: tasks)
    }
    
    private func show (tasks: [Task]) {
        
        // Find the real number of worked hours
        let reports = reportsInteractor.reports(fromTasks: tasks, targetHoursInDay: nil)
        let message = reportsInteractor.toString(reports)
        
        let settings = SettingsInteractor().getAppSettings()
        workdayLength = TimeInteractor(settings: settings).workingDayLength()
        workedLength = StatisticsInteractor().duration(of: reports)
        let duration = (pref.bool(.enableRoundingDay) ? workdayLength : workedLength).secToPercent
        
        userInterface!.showDuration(duration)
        userInterface!.showWorklog(message)
        setupRoundingButton(workdayLength: workdayLength.secToPercent,
                            workedLength: workedLength.secToPercent)
    }
    
    private func setupRoundingButton (workdayLength: TimeInterval, workedLength: TimeInterval) {
        userInterface!.showRounding(enabled: pref.bool(.enableRoundingDay),
                                    title: "Round worklogs duration to \(String(describing: workdayLength)) hours")
    }
    
    func save (worklog: String) {
        userInterface!.showJiraMessage("", isError: false)

        // Save to jira tempo
        let isRoundingEnabled = pref.bool(.enableRoundingDay)
        
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
    }
    
    func enableRounding (_ enabled: Bool) {
        pref.set(enabled, forKey: .enableRoundingDay)
        let duration = enabled ? workdayLength : workedLength
        userInterface!.showDuration(duration.secToPercent)
    }
}

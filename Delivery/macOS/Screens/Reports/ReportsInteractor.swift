//
//  ReportsInteractor.swift
//  Jirassic
//
//  Created by Cristian Baluta on 27/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences
import RCLog

protocol ReportsInteractorInput: class {

    func reloadTasks (inDay day: Day)
    func reloadTasks (inMonth day: Day)
}

protocol ReportsInteractorOutput: class {

    func tasksDidLoad (_ tasks: [Task])
}

class ReportsInteractor {

    weak var presenter: ReportsInteractorOutput?
    
    private let tasksReader: ReadTasksInteractor!
    private let moduleGit = ModuleGitLogs()
    private let moduleCalendar = ModuleCalendar()
    private let pref = RCPreferences<LocalPreferences>()
    private var currentTasks = [Task]()
    private var currentDateStart: Date?
    
    init() {
        tasksReader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)
    }
}

extension ReportsInteractor: ReportsInteractorInput {

    func reloadTasks (inDay day: Day) {

        let dateStart = day.dateStart
        let dateEnd = day.dateEnd ?? dateStart.endOfDay()
        currentDateStart = dateStart
        reloadTasks(dateStart: dateStart, dateEnd: dateEnd)
    }

    func reloadTasks (inMonth day: Day) {

        let dateStart = day.dateStart.startOfMonth()
        let dateEnd = dateStart.endOfMonth()
        currentDateStart = dateStart
        reloadTasks(dateStart: dateStart, dateEnd: dateEnd)
    }

    private func reloadTasks (dateStart: Date, dateEnd: Date) {
        
        
    }
    
}

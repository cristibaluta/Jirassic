//
//  MainPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences

enum ListType: Int {
    
    case tasks = 0
    case reports = 1
    case projects = 2
}

protocol MainPresenterInput: class {
    
    func viewDidAppear()
    func select(listType: ListType)
}

protocol MainPresenterOutput: class {
    
    func showWarning (_ show: Bool)
//    func showMessage (_ message: MessageViewModel)
    func showCalendar()
    func showTasks()
    func showReports()
    func showProjects()
    func removeCalendar()
    func removeTasks()
    func removeReports()
    func removeProjects()
    func select(listType: ListType)
}

class MainPresenter {
    
    weak var appWireframe: AppWireframe?
    weak var ui: MainPresenterOutput?
    
    private var selectedListType = ListType.tasks
    private let pref = RCPreferences<LocalPreferences>()
    private var extensions = ExtensionsInteractor()
    private var lastSelectedDay: Day?
}

extension MainPresenter: MainPresenterInput {
    
    func viewDidAppear() {
        ui!.showWarning(false)
        ui!.showCalendar()
        let lastType = TaskTypeSelection().lastType()
        select(listType: lastType)
        ui!.select(listType: lastType)
        // Check for compatibility of components
        extensions.getVersions { [weak self] (versions) in
            guard let userInterface = self?.ui else {
                return
            }
            let compatibility = Versioning(versions: versions)
            if compatibility.shellScript.available {
                userInterface.showWarning(!compatibility.jirassic.compatible || !compatibility.jit.compatible)
            } else {
                userInterface.showWarning(false)
            }
        }
    }
    
    func select(listType: ListType) {
        TaskTypeSelection().setType(listType)
        ui!.removeTasks()
        ui!.removeReports()
        ui!.removeProjects()
        switch listType {
            case .tasks:
                ui!.showCalendar()
                ui!.showTasks()
            case .reports:
                ui!.showCalendar()
                ui!.showReports()
            case .projects:
                ui!.removeCalendar()
                ui!.showProjects()
        }
    }
}

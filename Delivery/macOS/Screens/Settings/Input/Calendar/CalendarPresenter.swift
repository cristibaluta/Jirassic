//
//  CalendarPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/07/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa

protocol CalendarPresenterInput: class {
    
    func enable (_ enabled: Bool)
    func refresh ()
    func authorize()
}

protocol CalendarPresenterOutput: class {
    
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setCalendarStatus (authorized: Bool, enabled: Bool)
}

class CalendarPresenter {
    
    weak var userInterface: CalendarPresenterOutput?
    private let calendarModule = ModuleCalendar()
    private let pref = RCPreferences<LocalPreferences>()
    
}

extension CalendarPresenter: CalendarPresenterInput {

    func enable (_ enabled: Bool) {
        pref.set(enabled, forKey: .enableCalendar)
    }
    
    func authorize() {
        calendarModule.authorize { (authorized) in
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    func refresh() {
        
        if calendarModule.isAuthorizationDetermined {
            
            userInterface!.setStatusImage(calendarModule.isAuthorized ? NSImage.Name.statusAvailable : NSImage.Name.statusPartiallyAvailable)
            userInterface!.setStatusText(calendarModule.isAuthorized ? "Calendar.app is accessible" : "Calendar.app was not authorized")
            userInterface!.setCalendarStatus (authorized: calendarModule.isAuthorized, enabled: pref.bool(.enableCalendar))
        } else {
            userInterface!.setStatusImage(NSImage.Name.statusUnavailable)
            userInterface!.setStatusText("Calendar.app was not authorized yet")
            userInterface!.setCalendarStatus (authorized: calendarModule.isAuthorized, enabled: pref.bool(.enableCalendar))
        }
    
//            userInterface.setPaths(wself.localPreferences.string(.settingsGitPaths),
//                                   enabled: wself.localPreferences.bool(.enableGit))
//
//            userInterface.setEmails(wself.localPreferences.string(.settingsGitAuthors),
//                                    enabled: wself.localPreferences.bool(.enableGit))
//
//            userInterface.setButEnable(on: wself.localPreferences.bool(.enableGit),
//                                       enabled: commandInstalled)
//
//            userInterface.setButInstall(enabled: wself.isShellScriptInstalled == false)
//        })
    }
}

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
    func enableCalendar (_ calendarTitle: String)
    func disableCalendar (_ calendarTitle: String)
    func refresh ()
    func authorize()
}

protocol CalendarPresenterOutput: class {
    
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setCalendarStatus (authorized: Bool, enabled: Bool)
    func setCalendars (_ calendars: [String], selected: [String])
}

class CalendarPresenter {
    
    weak var userInterface: CalendarPresenterOutput?
    private let calendarModule = ModuleCalendar()
    private let pref = RCPreferences<LocalPreferences>()

    private var selectedCalendars: [String] {
        get {
            return pref.string(.settingsSelectedCalendars).split(separator: ",").map({String($0)})
        }
        set {
            pref.set(newValue.joined(separator: ","), forKey: .settingsSelectedCalendars)
        }
    }
}

extension CalendarPresenter: CalendarPresenterInput {

    func enable (_ enabled: Bool) {
        pref.set(enabled, forKey: .enableCalendar)
    }

    func enableCalendar (_ calendarTitle: String) {
        var calendars = selectedCalendars
        calendars.append(calendarTitle)
        selectedCalendars = calendars
    }

    func disableCalendar (_ calendarTitle: String) {
        let calendars = selectedCalendars.filter() { $0 != calendarTitle }
        selectedCalendars = calendars
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
        userInterface!.setCalendars(calendarModule.allCalendarsTitles(), selected: selectedCalendars)
    }
}

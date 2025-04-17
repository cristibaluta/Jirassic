//
//  CalendarPresenter.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/07/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import Cocoa
import RCPreferences

protocol CalendarSettingsPresenterInput: AnyObject {

    func enable (_ enabled: Bool)
    func enableCalendar (_ calendarTitle: String)
    func disableCalendar (_ calendarTitle: String)
    func refresh ()
    func authorize()
}

protocol CalendarSettingsPresenterOutput: AnyObject {

    func enable (_ enabled: Bool)
    func setStatusImage (_ imageName: NSImage.Name)
    func setStatusText (_ text: String)
    func setDescriptionText (_ text: String)
    func setCalendarStatus (authorized: Bool, enabled: Bool)
    func setCalendars (_ calendars: [String], selected: [String])
}

class CalendarSettingsPresenter {
    
    weak var userInterface: CalendarSettingsPresenterOutput?
    private let calendarModule = ModuleCalendar()
    private let pref = RCPreferences<LocalPreferences>()
}

extension CalendarSettingsPresenter: CalendarSettingsPresenterInput {

    func enable (_ enabled: Bool) {
        pref.set(enabled, forKey: .enableCalendar)
        userInterface!.enable(enabled)
    }

    func enableCalendar (_ calendarTitle: String) {
        var calendars = calendarModule.selectedCalendarNames
        calendars.append(calendarTitle)
        calendarModule.selectedCalendarNames = calendars
    }

    func disableCalendar (_ calendarTitle: String) {
        let calendars = calendarModule.selectedCalendarNames.filter() { $0 != calendarTitle }
        calendarModule.selectedCalendarNames = calendars
    }

    func authorize() {
        calendarModule.authorize { authorized in
            DispatchQueue.main.async {
                self.refresh()
            }
        }
    }
    
    func refresh() {
        
        if calendarModule.isAuthorizationDetermined {
            userInterface!.setStatusImage(calendarModule.isAuthorized
                                          ? NSImage.statusAvailableName
                                          : NSImage.statusPartiallyAvailableName)
            userInterface!.setStatusText(calendarModule.isAuthorized
                                         ? "Calendar.app is accessible"
                                         : "Calendar.app is not authorized")
            userInterface!.setDescriptionText(calendarModule.isAuthorized
                                              ? "Events from the selected calendars will appear in Jirassic as tasks"
                                              : "Authorize from: Settings.app / Privacy & Security / Calendars")
            userInterface!.setCalendarStatus(authorized: calendarModule.isAuthorized,
                                             enabled: pref.bool(.enableCalendar))
        } else {
            userInterface!.setStatusImage(NSImage.statusUnavailableName)
            userInterface!.setStatusText("Calendar.app was not authorized yet")
            userInterface!.setCalendarStatus(authorized: calendarModule.isAuthorized,
                                             enabled: pref.bool(.enableCalendar))
        }

        userInterface!.setCalendars(calendarModule.allCalendarsTitles(),
                                    selected: calendarModule.selectedCalendarNames)
        userInterface!.enable(calendarModule.isAuthorized && pref.bool(.enableCalendar))
    }
}

//
//  ModuleCalendar.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/07/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import EventKit
import RCPreferences

class ModuleCalendar {

    private var eventStore = EKEventStore()
    private let pref = RCPreferences<LocalPreferences>()
    
    var isAuthorizationDetermined: Bool {
        return EKEventStore.authorizationStatus(for: .event) != .notDetermined
    }

    var selectedCalendarNames: [String] {
        get {
            return pref.string(.settingsSelectedCalendars).split(separator: ",").map({String($0)})
        }
        set {
            pref.set(newValue.joined(separator: ","), forKey: .settingsSelectedCalendars)
        }
    }

    var isAuthorized: Bool {
        if #available(macOS 14.0, *) {
            return EKEventStore.authorizationStatus(for: .event) == .fullAccess
        } else {
            return EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }

    func authorize(_ completion: @escaping (Bool) -> Void) {
        if #available(macOS 14.0, *) {
            eventStore.requestFullAccessToEvents { granted, error in
                self.eventStore = EKEventStore()
                completion(granted)
            }
        } else {
            eventStore.requestAccess(to: .event) { granted, error in
                self.eventStore = EKEventStore()
                completion(granted)
            }
        }
    }
    
    var allCalendars: [EKCalendar] {
        eventStore.calendars(for: .event)
    }

    func allCalendarsTitles() -> [String] {
        return allCalendars.map({ $0.title })
    }

    func events (dateStart: Date, dateEnd: Date, completion: @escaping (([Task]) -> Void)) {
        
        guard isAuthorized else {
            completion([])
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let calendars = self.allCalendars.filter { self.selectedCalendarNames.contains($0.title) }
            let eventsPredicate = self.eventStore.predicateForEvents(withStart: dateStart,
                                                                     end: dateEnd,
                                                                     calendars: calendars)
            let events: [EKEvent] = self.eventStore.events(matching: eventsPredicate)

            let tasks: [Task] = events.map { event in
                Task(lastModifiedDate: nil,
                     startDate: event.startDate,
                     endDate: event.endDate,
                     notes: event.title,
                     taskNumber: nil,
                     taskTitle: event.title,
                     taskType: .calendar,
                     objectId: nil)// A task without id means that it's not saved in db
            }
            DispatchQueue.main.async {
                completion(tasks)
            }
        }
    }

}

//
//  ModuleCalendar.swift
//  Jirassic
//
//  Created by Cristian Baluta on 04/07/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import EventKit

class ModuleCalendar {

    private let eventStore = EKEventStore()
    private let pref = RCPreferences<LocalPreferences>()
    
    var isAuthorizationDetermined: Bool {
        return EKEventStore.authorizationStatus(for: .event) != .notDetermined
    }
    
    var isAuthorized: Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
    }
    
    var selectedCalendars: [String] {
        get {
            return pref.string(.settingsSelectedCalendars).split(separator: ",").map({String($0)})
        }
        set {
            pref.set(newValue.joined(separator: ","), forKey: .settingsSelectedCalendars)
        }
    }
    
    func authorize(_ completion: @escaping (Bool) -> Void) {
        eventStore.requestAccess(to: .event) { (granted, error) in
            completion(granted)
        }
    }
    
    func allCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }

    func allCalendarsTitles() -> [String] {
        return allCalendars().map({$0.title})
    }

    func events (dateStart: Date, dateEnd: Date, completion: @escaping (([Task]) -> Void)) {
        
        guard isAuthorized else {
            completion([])
            return
        }
        
        var tasks = [Task]()

        authorize { (granted) in
            
            guard granted else {
                completion([])
                return
            }
            for calendar in self.allCalendars() {
                
                if self.selectedCalendars.contains(calendar.title) {
                    
                    let eventsPredicate = self.eventStore.predicateForEvents(withStart: dateStart, end: dateEnd, calendars: [calendar])
                    let events: [EKEvent] = self.eventStore.events(matching: eventsPredicate)
                    
                    for event in events {
                        let task = Task(lastModifiedDate: nil,
                                        startDate: event.startDate,
                                        endDate: event.endDate,
                                        notes: event.title,
                                        taskNumber: TaskType.calendar.defaultTaskNumber,
                                        taskTitle: event.title,
                                        taskType: .calendar,
                                        objectId: String.generateId())
                        tasks.append(task)
                    }
                    DispatchQueue.main.async {
                        completion(tasks)
                    }
                }
            }
        }
    }
}

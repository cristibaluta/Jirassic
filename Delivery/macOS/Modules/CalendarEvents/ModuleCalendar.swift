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
    private var allowedCalendars: [String] = ["Work", "Calendar"]

    var isAuthorizationDetermined: Bool {
        return EKEventStore.authorizationStatus(for: .event) != .notDetermined
    }
    
    var isAuthorized: Bool {
        return EKEventStore.authorizationStatus(for: .event) == .authorized
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

    func events (onDate date: Date, completion: @escaping (([Task]) -> Void)) {
        
        guard isAuthorized else {
            completion([])
            return
        }
        
        let startDate = date.startOfDay()
        let endDate = date.endOfDay()

        var tasks = [Task]()

        authorize { (granted) in

            guard granted else {
                return
            }
            let allcalendars = self.allCalendars()
            for calendar in allcalendars {
                RCLog(calendar.title)
                if self.allowedCalendars.contains(calendar.title) {
                    let eventsPredicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                    let events: [EKEvent] = self.eventStore.events(matching: eventsPredicate)
                    for event in events {
//                            RCLog(event)
                        RCLog(event.startDate)
                        RCLog(event.endDate)
                        RCLog(event.title)

                        let task = Task(lastModifiedDate: nil,
                                        startDate: event.startDate,
                                        endDate: event.endDate,
                                        notes: event.title,
                                        taskNumber: "event",
                                        taskTitle: event.title,
                                        taskType: .meeting,
                                        objectId: String.random())
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

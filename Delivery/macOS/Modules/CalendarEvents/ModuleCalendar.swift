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

    let eventStore = EKEventStore()

    func allCalendars() -> [EKCalendar] {
        return eventStore.calendars(for: .event)
    }

    func events (onDate date: Date, completion: @escaping (([Task]) -> Void)) {
        // Create a date formatter instance to use for converting a string to a date
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = date.startOfDay()// dateFormatter.date(from: "2018-07-04")
        let endDate = date.endOfDay()// dateFormatter.date(from: "2018-07-06")

        var tasks = [Task]()

        eventStore.requestAccess(to: .event) { (granted, error) in

            if granted {
                let allcalendars = self.allCalendars()
                for calendar in allcalendars {
                    RCLog(calendar.title)
                    if calendar.title == "Calendar" || calendar.title == "Work" {
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

            // Use an event store instance to create and properly configure an NSPredicate

//                .sort() {
//                (e1: EKEvent, e2: EKEvent) -> Bool in
//                return e1.startDate.compare(e2.startDate) == ComparisonResult.OrderedAscending
//            }
    }
}

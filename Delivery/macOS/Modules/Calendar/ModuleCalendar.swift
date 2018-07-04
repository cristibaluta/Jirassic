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
    var events: [EKEvent]?

    func loadEvents() {
        // Create a date formatter instance to use for converting a string to a date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let startDate = dateFormatter.date(from: "2018-07-04")
        let endDate = dateFormatter.date(from: "2018-07-06")

        if let startDate = startDate, let endDate = endDate {

//            RCLog(eventStore.sources)

            eventStore.requestAccess(to: .event) { (granted, error) in

                if granted {
                    let allcalendars = self.eventStore.calendars(for: .event)
//                    RCLog(allcalendars)
                    for calendar in allcalendars {
                        RCLog(calendar.title)
                        if calendar.title == "Calendar" || calendar.title == "Work" {
                            let eventsPredicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: [calendar])
                            self.events = self.eventStore.events(matching: eventsPredicate)
                            RCLog(self.events)
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
}

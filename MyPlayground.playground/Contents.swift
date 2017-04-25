//: Playground - noun: a place where people can play

import Cocoa

let ymdhmsUnitFlags: Set<Calendar.Component> = [.year, .month, .weekday, .day, .hour, .minute, .second]
let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)

extension Date {
    
    init (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int=0) {
        
        var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: Date())
        comps.year = year
        comps.month = month
        comps.day = day
        comps.hour = hour
        comps.minute = minute
        comps.second = second
        
        self.init(timeInterval: 0, since: gregorian.date(from: comps)!)
    }
}


print(Date())
Date(year: 2017, month: 5, day: 5, hour: 0, minute:0)
NSCalendar.current.isDate(Date(year: 2017, month: 5, day: 5, hour: 0, minute:0), 
                          inSameDayAs: Date(year: 2017, month: 5, day: 5, hour: 23, minute:59))
print ( gregorian.startOfDay(for: Date()) )
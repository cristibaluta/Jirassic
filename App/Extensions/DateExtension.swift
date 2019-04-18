//
//  DateExtension.swift
//  Spoto
//
//  Created by Baluta Cristian on 05/12/14.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import Foundation

let ymdUnitFlags: Set<Calendar.Component> = [.year, .month, .day]
let ymdhmsUnitFlags: Set<Calendar.Component> = [.year, .month, .weekday, .day, .hour, .minute, .second]
let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)

extension Date {
	
	init (hour: Int, minute: Int, second: Int = 0) {
		self.init(date: Date(), hour: hour, minute: minute, second: second)
	}
	
	init (date: Date, hour: Int, minute: Int, second: Int = 0) {
		
		var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: date)
		comps.hour = hour
		comps.minute = minute
		comps.second = 0
		
		self.init(timeInterval: 0, since: gregorian.date(from: comps)!)
	}
	
	init (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int = 0) {
		
		var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: Date())
		comps.year = year
		comps.month = month
		comps.day = day
		comps.hour = hour
		comps.minute = minute
		comps.second = second
		
		self.init(timeInterval: 0, since: gregorian.date(from: comps)!)
	}
    
    init (YYYYMMddString: String) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY.MM.dd"
        let date = dateFormatter.date(from: YYYYMMddString)
        
        self.init(timeInterval: 0, since: date!)
    }
}

extension Date {
	
	func HHmmddMM() -> String {
		let f = DateFormatter()
		f.dateFormat = "HH:mm • dd MMM"
		return f.string(from: self)
	}
	
	func MMMMdd() -> String {
		let f = DateFormatter()
		f.dateFormat = "MMMM dd"
		return f.string(from: self)
	}
	
	func HHmm() -> String {
		let f = DateFormatter()
		f.dateFormat = "HH:mm"
		return f.string(from: self)
	}
	
	func HHmmGMT() -> String {
		let f = DateFormatter()
		f.timeZone = TimeZone(abbreviation: "GMT")
		f.dateFormat = "HH:mm"
		return f.string(from: self)
	}
	
	func EEMMMMdd() -> String {
		let f = DateFormatter()
		f.dateFormat = "EE, MMMM dd"
		return f.string(from: self)
	}
	
	func ddEEE() -> String {
		let f = DateFormatter()
		f.dateFormat = "dd • EEE"
		return f.string(from: self)
	}
	
    // eg. Thursday, February 01
	func EEEEMMMMdd() -> String {
		let f = DateFormatter()
		f.dateFormat = "EEEE, MMMM dd"
		return f.string(from: self)
	}
    
    // eg. Thursday, Feb 01
    func EEEEMMMdd() -> String {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMM dd"
        return f.string(from: self)
    }
    
    func YYYYMMddHHmmss() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f.string(from: self)
    }
    
    func YYYYMMddHHmmssGMT() -> String {
        let f = DateFormatter()
        f.timeZone = TimeZone(abbreviation: "GMT")
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f.string(from: self)
    }
    
    #warning("if the date is right at the begining of the day the conversion returns the previous day because of the timezone")
    func YYYYMMddT00() -> String {
        let f = DateFormatter()
//        f.timeZone = TimeZone(abbreviation: "GMT")
        f.dateFormat = "YYYY-MM-dd"
        let day = f.string(from: self)
//        f.dateFormat = "HH:mm"
        let hour = "00:00"//f.string(from: self)
        return day + "T" + hour + ":00.000+0000"
    }
    
    func YY() -> String {
        let f = DateFormatter()
        f.dateFormat = "YY"
        return f.string(from: self)
    }
    
    func YYYY() -> String {
        let f = DateFormatter()
        f.dateFormat = "YYYY"
        return f.string(from: self)
    }
}

extension Date {
    
	func weekInterval() -> String {
		let bounds = self.weekBounds()
		let f = DateFormatter()
		f.dateFormat = "MMM dd"
		if bounds.0.isSameMonthAs(bounds.1) {
			return "\(f.string(from: bounds.0)) - \(bounds.1.day())   '\(bounds.0.YY())"
		}
		return "\(f.string(from: bounds.0)) - \(f.string(from: bounds.1))   '\(bounds.0.YY())"
	}
}

extension Date {
    
	@inline(__always) func isSameMonthAs (_ month: Date) -> Bool {
		return self.year() == month.year() && self.month() == month.month()
	}
	
	@inline(__always) func isSameWeekAs (_ month: Date) -> Bool {
		return self.year() == month.year() && self.week() == month.week()
	}
	
	@inline(__always) func isSameDayAs (_ date: Date) -> Bool {
        return NSCalendar.current.isDate(self, inSameDayAs: date)
	}
    
    @inline(__always) func isAlmostSameHourAs (_ date: Date, devianceSeconds: Double = 600.0) -> Bool {
        let timestampDiff = date.timeIntervalSince(self)
        return abs(timestampDiff) <= devianceSeconds
    }
    
    @inline(__always) func isToday() -> Bool {
        return isSameDayAs( Date() )
    }
    
    func isWeekend() -> Bool {
        return gregorian.isDateInWeekend(self)
    }
	
	func daysInMonth() -> Int {
		
		let daysRange = gregorian.range(of: Calendar.Component.day, in: Calendar.Component.month, for: self)
		
		return daysRange!.count as Int
	}
    
    func components() -> (hour: Int, minute: Int) {
        let comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
        return (hour: comps.hour!, minute: comps.minute!)
    }
	
	@inline(__always) func year() -> Int {
		let comps = gregorian.dateComponents(ymdUnitFlags, from: self)
		return comps.year!
	}
	
	@inline(__always) func month() -> Int {
		let comps = gregorian.dateComponents(ymdUnitFlags, from: self)
		return comps.month!
	}
	
	@inline(__always) func day() -> Int {
		let comps = gregorian.dateComponents(ymdUnitFlags, from: self)
		return comps.day!
	}
	
	@inline(__always) func week() -> Int {
		let comps = gregorian.dateComponents([Calendar.Component.weekOfYear], from: self)
		return comps.weekOfYear!
	}

    func round (minutesPrecision precision: Int = 6) -> Date {

        var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
        let hm = minutesToHours(minutes: comps.minute!, resultingMinutesPrecision: precision)
        comps.hour = comps.hour! + hm.hour
        comps.minute = hm.min
        comps.second = 0

        return gregorian.date(from: comps)!
    }

    func dateByUpdating (hour: Int, minute: Int, second: Int = 0) -> Date {
		
		var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
		comps.hour = hour
		comps.minute = minute
		comps.second = second
		
		return gregorian.date(from: comps)!
	}
    
    func dateByKeepingTime() -> Date {
        let comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
        return Date().dateByUpdating(hour: comps.hour!, minute: comps.minute!)
    }
	
	static func parseHHmm (_ hhmm: String) -> (hour: Int, min: Int) {
		let hm = hhmm.components(separatedBy: ":")
        let hh = Int(hm[0]) ?? 0
        let mm = Int(hm[1]) ?? 0
		return (hour: hh, min: mm)
	}
}

extension Date {
    
    static func getMonthsBetween (startDate: Date, endDate: Date) -> Array<Date> {
        
        var dates: [Date] = [Date]()
        var monthDifference = DateComponents()
        var monthOffset: Int = 0
        var nextDate = startDate
        
        while nextDate.compare(endDate) == ComparisonResult.orderedAscending {
            monthOffset += 1
            monthDifference.month = monthOffset
            nextDate = gregorian.date(byAdding: monthDifference, to: startDate)!
            dates.append(nextDate)
        }
        
        return dates;
    }

    func startOfMonth() -> Date {
        return gregorian.date(from: gregorian.dateComponents([.year, .month], from: gregorian.startOfDay(for: self)))!
    }

    func endOfMonth() -> Date {
        return gregorian.date(byAdding: DateComponents(month: 1, day: -1, hour: 23, minute: 59, second: 59), to: self.startOfMonth())!
    }
}

extension Date {
    
    func startOfWeek() -> Date {
        
        var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
        comps.day = comps.day! - (comps.weekday! - 1) + 1// 1 because weekday starts with 1, and 1 because weekday starts sunday
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        comps.weekday = 1
        
        return gregorian.date(from: comps)!
    }
    
    func endOfWeek() -> Date {
        
        var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
        comps.day = comps.day! + (7 - comps.weekday!) + 1
        comps.hour = 23
        comps.minute = 59
        comps.second = 59
        comps.weekday = 7
        
        return gregorian.date(from: comps)!
    }
    
    func weekBounds() -> (Date, Date) {
        return (self.startOfWeek(), self.endOfWeek())
    }
}

extension Date {
    
    func startOfDay() -> Date {
        
        var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        
        return gregorian.date(from: comps)!
    }

    func startOfNextDay() -> Date {

        var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
        comps.day = comps.day! + 1
        comps.hour = 0
        comps.minute = 0
        comps.second = 0

        return gregorian.date(from: comps)!
    }

    func endOfDay() -> Date {
        
        var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: self)
        comps.hour = 23
        comps.minute = 59
        comps.second = 59
        
        return gregorian.date(from: comps)!
    }
    
    func dayBounds() -> (Date, Date) {
        return (self.startOfDay(), self.endOfDay())
    }
}

extension Date {
    
    private func minutesToHours (minutes: Int, resultingMinutesPrecision precision: Int) -> (hour: Int, min: Int) {

        let rest = minutes % precision
        let newMin = rest == 0 ? minutes : (minutes + precision - rest)
        
        return (newMin >= 60 ? 1 : 0, newMin >= 60 ? 0 : newMin)
    }
}

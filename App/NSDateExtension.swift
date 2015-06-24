//
//  DateExtension.swift
//  Spoto
//
//  Created by Baluta Cristian on 05/12/14.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import Foundation

let ymdUnitFlags = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
let ymdhmsUnitFlags: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth |
										NSCalendarUnit.CalendarUnitDay | NSCalendarUnit.CalendarUnitHour |
										NSCalendarUnit.CalendarUnitMinute | NSCalendarUnit.CalendarUnitSecond
let gregorian = NSCalendar(identifier: NSCalendarIdentifierGregorian)

extension NSDate {
	
	func HHmmddMM() -> String {
		let f = NSDateFormatter()
		f.dateFormat = "HH:mm • dd MMM"
		return f.stringFromDate(self)
	}
	
	func MMdd() -> String {
		let f = NSDateFormatter()
		f.dateFormat = "MMMM dd"
		return f.stringFromDate(self)
	}
	
	func HHmm() -> String {
		let f = NSDateFormatter()
		f.dateFormat = "HH:mm"
		return f.stringFromDate(self)
	}
	
	func HHmmGMT() -> String {
		let f = NSDateFormatter()
		f.timeZone = NSTimeZone(abbreviation: "GMT")
		f.dateFormat = "HH:mm"
		return f.stringFromDate(self)
	}
	
	func EEMMdd() -> String {
		let f = NSDateFormatter()
		f.dateFormat = "EE, MMMM dd"
		return f.stringFromDate(self)
	}
	
	func ddEEEEE() -> String {
		let f = NSDateFormatter()
		f.dateFormat = "dd • EEE"
		return f.stringFromDate(self)
	}
	
	func EEEEMMdd() -> String {
		let f = NSDateFormatter()
		f.dateFormat = "EEEE, MMMM dd"
		return f.stringFromDate(self)
	}
	
	class func getMonthsBetween(startDate: NSDate, endDate: NSDate) -> Array<NSDate> {
	
		var dates: [NSDate] = [NSDate]()
		let monthDifference = NSDateComponents()
		var monthOffset: Int = 0
		var nextDate = startDate
	
		while nextDate.compare(endDate) == NSComparisonResult.OrderedAscending {
			monthDifference.month = monthOffset++
			nextDate = gregorian!.dateByAddingComponents(monthDifference,
				toDate: startDate, options: nil)!
			dates.append(nextDate)
		}
		
		return dates;
	}
	
	func firstDayThisMonth() -> NSDate {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: self)
		comps.day = 1
		comps.hour = 0
		comps.minute = 0
		comps.second = 0
		
		return gregorian!.dateFromComponents(comps)!
	}
	
	func isSameMonthAs(month: NSDate) -> Bool {
		return self.year() == month.year() && self.month() == month.month()
	}
	
	func isSameDayAs(date: NSDate) -> Bool {
		
		let compsSelf = gregorian!.components(ymdUnitFlags, fromDate: self)
		let compsRef = gregorian!.components(ymdUnitFlags, fromDate: date)
		
		return compsSelf.day == compsRef.day &&
			compsSelf.month == compsRef.month &&
			compsSelf.year == compsRef.year
	}
	
	func daysInMonth() -> Int {
		
		let daysRange = gregorian!.rangeOfUnit(NSCalendarUnit.CalendarUnitDay,
			inUnit: NSCalendarUnit.CalendarUnitMonth, forDate: self)
		
		return daysRange.length as Int
	}
	
	func year() -> Int {
		let comps = gregorian!.components(ymdUnitFlags, fromDate: self)
		return comps.year
	}
	
	func month() -> Int {
		let comps = gregorian!.components(ymdUnitFlags, fromDate: self)
		return comps.month
	}
	
	func day() -> Int {
		let comps = gregorian!.components(ymdUnitFlags, fromDate: self)
		return comps.day
	}
	
	func roundUp() -> NSDate {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: self)
		let hm = self.round(comps.minute)
		comps.hour = comps.hour + hm.hour
		comps.minute = hm.min
		comps.second = 0
		
		return gregorian!.dateFromComponents(comps)!
	}
	
	func secondsToPercentTime(time: Double) -> Double {
		return time / 3600
	}
	
	func updateHour(hour: Int, minute: Int) -> NSDate {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: self)
		comps.hour = hour
		comps.minute = minute
		comps.second = 0
		
		return gregorian!.dateFromComponents(comps)!
	}
	
	// MARK: Private
	
	private func round(min: Int) -> (hour: Int, min: Int) {
		if min < 22 {
			return (0, 15)
		} else if min < 38 {
			return (0, 30)
		} else if min < 52 {
			return (0, 45)
		} else {
			return (1, 0)
		}
	}
}

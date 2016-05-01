//
//  DateExtension.swift
//  Spoto
//
//  Created by Baluta Cristian on 05/12/14.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import Foundation

let ymdUnitFlags: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Day]
let ymdhmsUnitFlags: NSCalendarUnit = [NSCalendarUnit.Year, NSCalendarUnit.Month, NSCalendarUnit.Weekday, NSCalendarUnit.Day,
										NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
let gregorian = NSCalendar(identifier: NSCalendarIdentifierGregorian)

extension NSDate {
	
	convenience init (hour: Int, minute: Int, second: Int=0) {
		self.init(date: NSDate(), hour: hour, minute: minute, second: second)
	}
	
	convenience init (date: NSDate, hour: Int, minute: Int, second: Int=0) {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: date)
		comps.hour = hour
		comps.minute = minute
		comps.second = 0
		
		self.init(timeInterval: 0, sinceDate: gregorian!.dateFromComponents(comps)!)
	}
	
	convenience init (year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int=0) {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: NSDate())
		comps.year = year
		comps.month = month
		comps.day = day
		comps.hour = hour
		comps.minute = minute
		comps.second = second
		
		self.init(timeInterval: 0, sinceDate: gregorian!.dateFromComponents(comps)!)
	}
	
	// MARK: Formatting options
	
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
	
	func weekInterval() -> String {
		let bounds = self.weekBounds()
		let f = NSDateFormatter()
		f.dateFormat = "MMM dd"
		if bounds.0.isSameMonthAs(bounds.1) {
			return "\(f.stringFromDate(bounds.0)) - \(bounds.1.day())"
		}
		return "\(f.stringFromDate(bounds.0)) - \(f.stringFromDate(bounds.1))"
	}
	
	// MARK: 
	
	class func getMonthsBetween (startDate: NSDate, endDate: NSDate) -> Array<NSDate> {
	
		var dates: [NSDate] = [NSDate]()
		let monthDifference = NSDateComponents()
		var monthOffset: Int = 0
		var nextDate = startDate
	
		while nextDate.compare(endDate) == NSComparisonResult.OrderedAscending {
            monthOffset += 1
			monthDifference.month = monthOffset
			nextDate = gregorian!.dateByAddingComponents(monthDifference,
				toDate: startDate, options: [])!
			dates.append(nextDate)
		}
		
		return dates;
	}
	
	func startOfMonth() -> NSDate {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: self)
		comps.day = 1
		comps.hour = 0
		comps.minute = 0
		comps.second = 0
		
		return gregorian!.dateFromComponents(comps)!
	}
	
	func startOfWeek() -> NSDate {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: self)
		comps.day = comps.day - (comps.weekday - 1) + 1// 1 because weekday starts with 1, and 1 because weekday starts sunday
		comps.hour = 0
		comps.minute = 0
		comps.second = 0
		comps.weekday = 1
		
		return gregorian!.dateFromComponents(comps)!
	}
	
	func endOfWeek() -> NSDate {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: self)
		comps.day = comps.day + (7 - comps.weekday) + 1
		comps.hour = 23
		comps.minute = 59
		comps.second = 59
		comps.weekday = 7
		
		return gregorian!.dateFromComponents(comps)!
	}
	
	func weekBounds() -> (NSDate, NSDate) {
		return (self.startOfWeek(), self.endOfWeek())
	}
	
	@inline(__always) func isSameMonthAs (month: NSDate) -> Bool {
		return self.year() == month.year() && self.month() == month.month()
	}
	
	@inline(__always) func isSameWeekAs (month: NSDate) -> Bool {
		return self.year() == month.year() && self.week() == month.week()
	}
	
	@inline(__always) func isSameDayAs (date: NSDate) -> Bool {
		
		let compsSelf = gregorian!.components(ymdUnitFlags, fromDate: self)
		let compsRef = gregorian!.components(ymdUnitFlags, fromDate: date)
		
		return compsSelf.day == compsRef.day &&
			compsSelf.month == compsRef.month &&
			compsSelf.year == compsRef.year
	}
	
	func daysInMonth() -> Int {
		
		let daysRange = gregorian!.rangeOfUnit(NSCalendarUnit.Day,
			inUnit: NSCalendarUnit.Month, forDate: self)
		
		return daysRange.length as Int
	}
	
	@inline(__always) func year() -> Int {
		let comps = gregorian!.components(ymdUnitFlags, fromDate: self)
		return comps.year
	}
	
	@inline(__always) func month() -> Int {
		let comps = gregorian!.components(ymdUnitFlags, fromDate: self)
		return comps.month
	}
	
	@inline(__always) func day() -> Int {
		let comps = gregorian!.components(ymdUnitFlags, fromDate: self)
		return comps.day
	}
	
	@inline(__always) func week() -> Int {
		let comps = gregorian!.components(NSCalendarUnit.WeekOfYear, fromDate: self)
		return comps.weekOfYear
	}
	
	func round() -> NSDate {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: self)
		let hm = _round(comps.minute)
		comps.hour = comps.hour + hm.hour
		comps.minute = hm.min
		comps.second = 0
		
		return gregorian!.dateFromComponents(comps)!
	}
	
	func secondsToPercentTime (time: Double) -> Double {
		return time / 3600
	}
	
	func dateByUpdatingHour (hour: Int, minute: Int) -> NSDate {
		
		let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: self)
		comps.hour = hour
		comps.minute = minute
		comps.second = 0
		
		return gregorian!.dateFromComponents(comps)!
	}
	
	class func parseHHmm (hhmm: String) -> (hour: Int, min: Int) {
		let hm = hhmm.componentsSeparatedByString(":")
		return (hour: Int(hm.first!)!, min: Int(hm.last!)!)
	}
	
	// MARK: Round to nearest quarter
	
	private func _round (min: Int) -> (hour: Int, min: Int) {
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

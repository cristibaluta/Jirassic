//
//  DateExtension.swift
//  Spoto
//
//  Created by Baluta Cristian on 05/12/14.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import Foundation

let ymdUnitFlags = NSCalendarUnit.CalendarUnitYear | NSCalendarUnit.CalendarUnitMonth | NSCalendarUnit.CalendarUnitDay
let gregorian = NSCalendar(identifier: NSCalendarIdentifierGregorian)

extension NSDate {
	
	func HHmmddMM () -> String {
		let f = NSDateFormatter()
		f.dateFormat = "HH:mm • dd MMM"
		return f.stringFromDate(self)
	}
	
	func MMdd () -> String {
		let f = NSDateFormatter()
		f.dateFormat = "MMMM dd"
		return f.stringFromDate(self)
	}
	
	func HHmm () -> String {
		let f = NSDateFormatter()
		f.dateFormat = "HH:mm"
		return f.stringFromDate(self)
	}
	
	func DDMMdd () -> String {
		let f = NSDateFormatter()
		f.dateFormat = "DD, MMMM dd"
		return f.stringFromDate(self)
	}
	
	class func getMonthsBetween(startDate: NSDate, endDate: NSDate) -> Array<NSDate> {
	
		var dates: [NSDate] = [NSDate]()
		let monthDifference = NSDateComponents()
		var monthOffset: Int = 0
		var nextDate = startDate
	
		while nextDate.compare(endDate) == NSComparisonResult.OrderedAscending {
			monthDifference.month = monthOffset++
			nextDate = NSCalendar.currentCalendar().dateByAddingComponents(monthDifference,
				toDate: startDate, options: nil)!
			dates.append(nextDate)
		}
		
		return dates;
	}
	
	func firstDayThisMonth() -> NSDate {
		
		let unitFlags: NSCalendarUnit = NSCalendarUnit.CalendarUnitYear |
			NSCalendarUnit.CalendarUnitMonth |
			NSCalendarUnit.CalendarUnitDay |
			NSCalendarUnit.CalendarUnitHour |
			NSCalendarUnit.CalendarUnitMinute |
			NSCalendarUnit.CalendarUnitSecond
		let comps = gregorian!.components(unitFlags, fromDate: self)
		comps.day = 1
		comps.hour = 0
		comps.minute = 0
		comps.second = 0
	
		return gregorian!.dateFromComponents(comps)!
	}
	
	func isTheSameMonthAs(month: NSDate) -> Bool {
		return self.year() == month.year() && self.month() == month.month()
	}
	
	func isTheSameDayAs(date: NSDate) -> Bool {
		
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
}

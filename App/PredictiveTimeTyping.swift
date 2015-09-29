//
//  JLPredictiveTimeTyping.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class PredictiveTimeTyping: NSObject {

	override init() {
		
	}
	/*
    func timeByAdding(string: String, var to: String) -> String {
	
		var returnString = string
		
        if (string == "") {
            // Backspace
            if to.endIndex == 3 {
				to = to[NSMakeRange(0, 1)]
                return string
            }
            return to
        }
	
        let comps = to.componentsSeparatedByString(":")
        
        if comps.count == 2 {
        // Insert the minutes
        
        var m = 0
        var min = comps[1]
        
        if min.endIndex >= 2 {
            to = "\(comps[0]):\(min.substringWithRange(NSMakeRange(0, 1)))"
            return to
        }
        else {
            m = decimalValueOf(min, newText: string)
        }
        
        if (m >= 60) {
            return string
        }
        else if (m >= 10) {
            return to
        }
        else if (m >= 6) {
            returnString = "\(comps.first):0\(m)"
        }
        else if (m == 0) {
            returnString = "\(comps.first):00"
        }
        else if (m == 1) {
            returnString = "\(comps.first):15"
        }
        else if (m == 2) {
            returnString = "\(comps.first):20"
        }
        else if (m == 3) {
            returnString = "\(comps.first):30"
        }
        else if (m == 4) {
            returnString = "\(comps.first):45"
        }
        else if (m == 5) {
            returnString = "\(comps.first):50"
        }
		else {
            return string
        }
			
			// Insert the hour
			let hr: String = comps[0]
			let h = decimalValueOf(hr, newText: string)
			
        if (h >= 24) {
			returnString = "00:"
        }
        else if (h >= 10) {
			// Do not perform any edit on this hour
			returnString = "\(h):"
        }
        else if (h >= 3) {
			returnString = "0\(h):"
        }
        else {
            if (hr.length >= 1) {
                returnString = "0\(h):"
            }
            else {
                return to
            }
        }
        return string
        }
        
        return to
	}
	*/
    func dateFromStringHHmm (string: String) -> NSDate {
		
        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let comps = gregorian!.components(ymdhmsUnitFlags, fromDate: NSDate())
        
        let hm = string.componentsSeparatedByString(":")
        
        if (hm.count > 1) {
            comps.hour = Int(hm[0])!
            comps.minute = Int(hm[1])!
        }
        else {
            comps.hour = (hm.count == 1) ? Int(hm[0])! : 19;
            comps.minute = 0
        }
        
        return gregorian!.dateFromComponents(comps)!
    }
    
    func decimalValueOf (existingText: String, newText: String) -> Int {
        
//        if existingText.length() > 0 {
//            return Int(existingText)! * 10 + Int(newText)!;
//        }
		
        return Int(newText)!
	}
}

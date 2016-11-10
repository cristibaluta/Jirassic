//
//  PredictiveTimeTyping.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class PredictiveTimeTyping {
	
    func timeByAdding (_ string: String, to: String) -> String {
	
		var returnString = string
		
		// Deal with backspace
        if (string == "") {
			let charsToDelete = to.characters.count == 3 ? 2 : 1
			let rangeToKeep = to.startIndex..<to.characters.index(to.endIndex, offsetBy: -charsToDelete)
			return to.substring(with: rangeToKeep)
        }
		
		let timeComps = to.components(separatedBy: ":")
		let hr: String = timeComps.first!
		
		// Deal with minutes
        if timeComps.count == 2 {
			var m = 0
			let min = timeComps.last!
			var minToAdd = ""
			
			if min.characters.count == 2 {
				let rangeToKeep = min.startIndex..<min.characters.index(min.endIndex, offsetBy: -1)
				return "\(hr):\(min.substring(with: rangeToKeep))\(string)"
			} else {
				m = decimalValueOf(min, newDigit: string)
			}
			
			if (m >= 10) { minToAdd = "\(m)"
			}
			else if (m >= 6) { minToAdd = "0\(m)"
			}
			else if (m == 0) { minToAdd = "00"
			}
			else if (m == 1) { minToAdd = "15"
			}
			else if (m == 2) { minToAdd = "20"
			}
			else if (m == 3) { minToAdd = "30"
			}
			else if (m == 4) { minToAdd = "45"
			}
			else if (m == 5) { minToAdd = "50"
			}
			returnString = "\(hr):\(minToAdd)"
        }
		// Deal with hours
		else {
			let h = decimalValueOf(hr, newDigit: string)
			
			if (h >= 24) {
				returnString = "00:"
			}
			else if (h >= 10) {
				// Do not perform any edit on hours from 10 to 23
				returnString = "\(h):"
			}
			else if (h >= 3) {
				returnString = "0\(h):"
			}
			else if (hr.characters.count >= 1) {
				returnString = "0\(h):"
			}
		}
		return returnString
	}
	
    func dateFromStringHHmm (_ string: String) -> Date {
		
        let gregorian = Calendar(identifier: Calendar.Identifier.gregorian)
        var comps = gregorian.dateComponents(ymdhmsUnitFlags, from: Date())
        let hm = string.components(separatedBy: ":")
		
		if (string.characters.count == 0) {
			comps.hour = 0
			comps.minute = 0
		}
        else if (hm.count > 1) {
            comps.hour = Int(hm[0])!
            comps.minute = Int(hm[1])!
        }
        else {
            comps.hour = (hm.count == 1) ? Int(hm[0])! : 19;
            comps.minute = 0
        }
        return gregorian.date(from: comps)!
    }
	
	// This method will combine strings and convert the result to number
    func decimalValueOf (_ existingText: String, newDigit: String) -> Int {
		
        if existingText.characters.count > 0 && newDigit.characters.count > 0 {
            return Int(existingText)! * 10 + Int(newDigit)!;
        }
		if let d = Int(newDigit) {
			return d
		} else {
			return 0
		}
	}
}

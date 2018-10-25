//
//  Day.swift
//  Jirassic
//
//  Created by Baluta Cristian on 30/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

// Represents a day in the calendar.
class Day: CustomStringConvertible {

    /// The date of the first task in the day
	let dateStart: Date
    /// The date of the last task in the day if it was finished
    let dateEnd: Date?
	
    init (dateStart: Date, dateEnd: Date?) {
		self.dateStart = dateStart
        self.dateEnd = dateEnd
	}

    var description: String {
        return "<Day dateStart: \(dateStart), dateEnd: \(String(describing: dateEnd))>"
    }
}

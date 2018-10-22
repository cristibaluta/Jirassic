//
//  Week.swift
//  Jirassic
//
//  Created by Baluta Cristian on 30/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

// Represents a week in the calendar
class Week {
	
	let date: Date
	var days = [Day]()
	
	init (date: Date) {
		self.date = date
	}
}

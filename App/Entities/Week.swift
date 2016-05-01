//
//  Week.swift
//  Jirassic
//
//  Created by Baluta Cristian on 30/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class Week {
	
	let date: NSDate
	var days = [Day]()
	
	init (date: NSDate) {
		self.date = date
	}
}

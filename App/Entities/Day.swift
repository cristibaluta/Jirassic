//
//  Day.swift
//  Jirassic
//
//  Created by Baluta Cristian on 30/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class Day {

	let dateStart: Date
    let dateEnd: Date?
	
    init (dateStart: Date, dateEnd: Date?) {
		self.dateStart = dateStart
        self.dateEnd = dateEnd
	}
}

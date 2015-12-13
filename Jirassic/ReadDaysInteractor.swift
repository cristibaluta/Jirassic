//
//  ReadDaysInteractor.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadDaysInteractor: NSObject {
	
	var data: DataManagerProtocol!
	
	convenience init (data: DataManagerProtocol) {
		self.init()
		self.data = data
	}
	
	func days() -> [Task] {
		
		var referenceDate = NSDate.distantFuture()
		
		let filteredData = data.allCachedTasks().filter { (task: Task) -> Bool in
			
			if let dateEnd = task.endDate {
				if dateEnd.isSameDayAs(referenceDate) == false {
					referenceDate = dateEnd
					return true
				}
			} else if let dateStart = task.startDate {
				if dateStart.isSameDayAs(referenceDate) == false {
					referenceDate = dateStart
					return true
				}
			}
			return false
		}
		
		return filteredData
	}
}

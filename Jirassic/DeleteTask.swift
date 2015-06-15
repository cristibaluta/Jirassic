//
//  DeleteTask.swift
//  Jirassic
//
//  Created by Baluta Cristian on 14/06/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class DeleteTask: NSObject {

	convenience init(task: Task) {
		self.init()
		task.deleteInBackgroundWithBlock({ (success, error) -> Void in
			println("delete task from Parse \(success) \(error)")
		})
	}
}

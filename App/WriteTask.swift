//
//  JLWriteLog.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class WriteTask: NSObject {
	
	convenience init(task: TaskProtocol) {
		self.init()
		if let task = task as? Task {
			task.saveEventually { (success, error) -> Void in
				println("saved task to Parse \(success) \(error)")
			}
		}
	}
}

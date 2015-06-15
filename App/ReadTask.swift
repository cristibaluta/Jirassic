//
//  JLReadLog.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

class ReadTask: NSObject {

	override init() {
		
	}
	
	func read() {
		
		var query = PFQuery(className: Task.parseClassName())
		/*query.findObjectsInBackgroundWithBlock {
		(objects: Array<AnyObject>!, error: NSError!) -> Void in
		RCLogO(objects!)
		for obj in objects {
		let o = obj as Task
		RCLogO(o.date_task_finished)
		RCLogO(o.notes)
		}
		}*/
		
		query.cachePolicy = .NetworkElseCache
		query.getObjectInBackgroundWithId("RNfW4Fgg5y") {
			(data: PFObject?, error: NSError?) -> Void in
			
			if error != nil {
				RCLogO(error)
			} else {
				RCLogO(data?["date_task_finished"])
				RCLogO(data?["notes"])
			}
		}
	}
}

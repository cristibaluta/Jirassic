//
//  Task.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

public class Task: PFObject, PFSubclassing {

	override init () {
		super.init()
	}
	
    dynamic public var date_task_finished :NSDate? {
        get {
            return objectForKey("date_task_finished") as! NSDate?
        }
        set {
            setObject(newValue!, forKey: "date_task_finished")
        }
    }
    
    dynamic public var notes :String? {
        get {
            return objectForKey("notes") as! String?
        }
        set {
            setObject(newValue!, forKey: "notes")
        }
    }
	
	dynamic public var task_nr :String? {
		get {
			return objectForKey("task_nr") as! String?
		}
		set {
			setObject(newValue!, forKey: "task_nr")
		}
	}
	
	dynamic public var task_type :NSNumber? {
		get {
			return objectForKey("task_type") as! NSNumber?
		}
		set {
			setObject(newValue!, forKey: "task_type")
		}
	}
	
	dynamic public var user: PFUser? {
		get {
			return objectForKey("user") as! PFUser?
		}
		set {
			setObject(newValue!, forKey: "user")
		}
	}
	
	public class func parseClassName() -> String {
		return "Task"
	}
}

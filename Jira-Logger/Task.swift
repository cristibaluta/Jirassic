//
//  Task.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

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
	
	public class func parseClassName() -> String {
		return "Task"
	}
}

//
//  Task.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

let kDateStartKey = "date_task_started"
let kDateFinishKey = "date_task_finished"
let kNotesKey = "notes"
let kTaskNrKey = "task_nr"
let kTypeKey = "task_type"
let kUserKey = "user"

enum TaskType: Int {
	case Issue = 0
	case Start = 1
	case Scrum = 2
	case Lunch = 3
}

public class Task: PFObject, PFSubclassing {

	override init () {
		super.init()
	}
	
	dynamic public var date_task_started :NSDate? {
		get {
			return objectForKey(kDateStartKey) as! NSDate?
		}
		set {
			setObject(newValue!, forKey: kDateStartKey)
		}
	}
	
    dynamic public var date_task_finished :NSDate? {
        get {
            return objectForKey(kDateFinishKey) as! NSDate?
        }
        set {
            setObject(newValue!, forKey: kDateFinishKey)
        }
    }
    
    dynamic public var notes :String? {
        get {
            return objectForKey(kNotesKey) as! String?
        }
        set {
            setObject(newValue!, forKey: kNotesKey)
        }
    }
	
	dynamic public var task_nr :String? {
		get {
			return objectForKey(kTaskNrKey) as! String?
		}
		set {
			setObject(newValue!, forKey: kTaskNrKey)
		}
	}
	
	dynamic public var task_type :NSNumber? {
		get {
			return objectForKey(kTypeKey) as! NSNumber?
		}
		set {
			setObject(newValue!, forKey: kTypeKey)
		}
	}
	
	dynamic public var user: PFUser? {
		get {
			return objectForKey(kUserKey) as! PFUser?
		}
		set {
			setObject(newValue!, forKey: kUserKey)
		}
	}
	
	public class func parseClassName() -> String {
		return "Task"
	}
}

//
//  JiraData.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

public class JiraData: PFObject, PFSubclassing {

    dynamic public var date_task_finished :NSDate {
        get {
            return objectForKey("date_task_finished") as NSDate
        }
        set {
            setObject(newValue, forKey: "date_task_finished")
        }
    }
    
    dynamic public var notes :String {
        get {
            return objectForKey("notes") as String
        }
        set {
            setObject(newValue, forKey: "notes")
        }
    }
	
	public class func parseClassName() -> String {
		return "JiraData"
	}
}

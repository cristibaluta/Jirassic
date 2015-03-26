//
//  JiraData.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

public class JiraData: PFObject, PFSubclassing {

	public var date_task_finished :NSDate?
	public var notes :String?
	
	public class func parseClassName() -> String {
		return "JiraData"
	}
}

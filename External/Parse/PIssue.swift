//
//  PIssue.swift
//  Jirassic
//
//  Created by Baluta Cristian on 21/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Foundation
import Parse

let kIssuesTypeKey = "issues_type"

public class PIssue: PFObject, PFSubclassing {
	
	dynamic public var notes: [String]? {
		get {
			return objectForKey(kIssuesTypeKey) as! [String]?
		}
		set {
			setObject(newValue!, forKey: kIssuesTypeKey)
		}
	}
	
	var user: PUser? {
		get {
			return objectForKey(kUserKey) as! PUser?
		}
		set {
			setObject(newValue!, forKey: kUserKey)
		}
	}
	
	public class func parseClassName() -> String {
		return "Issue"
	}
}

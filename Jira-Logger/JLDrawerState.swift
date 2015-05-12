//
//  JLDrawerState.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 11/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

enum DaysState: Int {
	case DaysClosed = 0
	case DaysOpen = 1
}

class JLDrawerState: NSObject {
	
	private let kDaysTableStateKey = "DaysTableStateKey"
	var state: DaysState = .DaysOpen
	
	func setState(s: DaysState) -> DaysState {
		NSUserDefaults.standardUserDefaults().setInteger(s.rawValue, forKey: kDaysTableStateKey)
		NSUserDefaults.standardUserDefaults().synchronize()
		return s
	}
	
	func previousState() -> DaysState {
		let previousState = NSUserDefaults.standardUserDefaults().integerForKey(kDaysTableStateKey)
		return previousState == 0 ? .DaysClosed : .DaysOpen
	}
	
	func toggleState() -> DaysState {
		return setState( previousState() == .DaysClosed ? .DaysOpen : .DaysClosed )
	}
}

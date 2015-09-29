//
//  JLDrawerState.swift
//  Jirassic
//
//  Created by Baluta Cristian on 11/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Foundation

enum DaysState: Int {
	case DaysClosed = 0
	case DaysOpen = 1
}

class DrawerState: NSObject {
	
	private let kDaysTableStateKey = "DaysTableStateKey"
	var state: DaysState = .DaysOpen
	
	func setState(state: DaysState) -> DaysState {
		NSUserDefaults.standardUserDefaults().setInteger(state.rawValue, forKey: kDaysTableStateKey)
		NSUserDefaults.standardUserDefaults().synchronize()
		return state
	}
	
	func previousState() -> DaysState {
		let previousState = NSUserDefaults.standardUserDefaults().integerForKey(kDaysTableStateKey)
		return previousState == 0 ? .DaysClosed : .DaysOpen
	}
	
	func toggleState() -> DaysState {
		return setState( previousState() == .DaysClosed ? .DaysOpen : .DaysClosed )
	}
}

//
//  SleepNotifications.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 10/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SleepNotifications: NSObject {

	var computerWentToSleep: (() -> ())?
	var computerWakeUp: (() -> ())?
	
	override init() {
		super.init()
		NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
			selector: Selector("receiveSleepNote:"), name: NSWorkspaceWillSleepNotification, object: nil)
		NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
			selector: Selector("receiveWakeNote:"), name: NSWorkspaceDidWakeNotification, object: nil)
	}
	
	deinit {
		NSWorkspace.sharedWorkspace().notificationCenter.removeObserver(self)
	}
	
	func receiveSleepNote(notif: NSNotification) {
		RCLog("receiveSleepNote: \(notif.name)")
//		computerWentToSleep!()
	}
	
	func receiveWakeNote(notif: NSNotification) {
		RCLog("receiveWakeNote: \(notif.name)")
//		computerWakeUp!()
	}
}

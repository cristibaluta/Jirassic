//
//  SleepNotifications.swift
//  Jirassic
//
//  Created by Baluta Cristian on 10/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class SleepNotifications: NSObject {

	var computerWentToSleep: (() -> ())?
	var computerWakeUp: (() -> ())?
	var lastSleepDate: NSDate?
	
	override init() {
		super.init()
		
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: #selector(SleepNotifications.receiveSleepNotification(_:)),
			name: NSWorkspaceWillSleepNotification, object: nil)
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: #selector(SleepNotifications.receiveSleepNotification(_:)),
			name: NSWorkspaceScreensDidSleepNotification, object: nil)
		NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: #selector(SleepNotifications.receiveWakeNotification(_:)),
			name: NSWorkspaceDidWakeNotification, object: nil)
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: #selector(SleepNotifications.receiveWakeNotification(_:)),
			name: NSWorkspaceScreensDidWakeNotification, object: nil)
	}
	
	deinit {
		NSWorkspace.sharedWorkspace().notificationCenter.removeObserver(self)
	}
	
	func receiveSleepNotification (notif: NSNotification) {
		RCLogO(notif)
		lastSleepDate = NSDate()
		computerWentToSleep?()
	}
	
	func receiveWakeNotification (notif: NSNotification) {
		RCLogO(notif)
		computerWakeUp?()
	}
}

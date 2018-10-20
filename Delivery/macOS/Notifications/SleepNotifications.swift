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
	var lastSleepDate: Date?
    var lastWakeDate: Date?
	
	override init() {
		super.init()
		
//        NSWorkspace.shared().notificationCenter.addObserver(
//            self,
//            selector: #selector(SleepNotifications.receiveSleepNotification(_:)),
//			name: NSNotification.Name.NSWorkspaceWillSleep,
//			object: nil)
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(SleepNotifications.receiveSleepNotification(_:)),
			name: NSWorkspace.screensDidSleepNotification,
			object: nil)
		
//        NSWorkspace.shared().notificationCenter.addObserver(
//            self,
//            selector: #selector(SleepNotifications.receiveWakeNotification(_:)),
//			name: NSNotification.Name.NSWorkspaceDidWake,
//			object: nil)
        
        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(SleepNotifications.receiveWakeNotification(_:)),
			name: NSWorkspace.screensDidWakeNotification,
			object: nil)
	}
	
	deinit {
		NSWorkspace.shared.notificationCenter.removeObserver(self)
	}
	
	@objc func receiveSleepNotification (_ notif: Notification) {
		RCLogO(notif)
		lastSleepDate = Date()
		computerWentToSleep?()
	}
	
	@objc func receiveWakeNotification (_ notif: Notification) {
		RCLogO(notif)
        lastWakeDate = Date()
		computerWakeUp?()
	}
}

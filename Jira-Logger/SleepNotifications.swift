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
            selector: Selector("receiveComputerSleepNotification:"), name: NSWorkspaceWillSleepNotification, object: nil)
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: Selector("receiveScreenSleepNotification:"), name: NSWorkspaceScreensDidSleepNotification, object: nil)
		NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: Selector("receiveComputerWakeNotification:"), name: NSWorkspaceDidWakeNotification, object: nil)
        NSWorkspace.sharedWorkspace().notificationCenter.addObserver(self,
            selector: Selector("receiveScreenWakeNotification:"), name: NSWorkspaceScreensDidWakeNotification, object: nil)
	}
	
	deinit {
		NSWorkspace.sharedWorkspace().notificationCenter.removeObserver(self)
	}
	
	func receiveComputerSleepNotification(notif: NSNotification) {
		RCLogO(notif)
		computerWentToSleep!()
	}
    
    func receiveScreenSleepNotification(notif: NSNotification) {
        RCLogO(notif)
        computerWentToSleep!()
    }
    
	func receiveComputerWakeNotification(notif: NSNotification) {
		RCLogO(notif)
		computerWakeUp!()
	}
    
    func receiveScreenWakeNotification(notif: NSNotification) {
        RCLogO(notif)
        computerWakeUp!()
    }
}

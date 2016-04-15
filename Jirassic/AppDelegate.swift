//
//  AppDelegate.swift
//  Jira Logger
//
//  Created by Cristian Baluta on 24/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

var sharedData: DataManagerProtocol!

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    @IBOutlet var popover: NSPopover?
    private var sleep: SleepNotifications?
	private let menu = MenuBarController()
	
	override init() {
		super.init()
		sharedData = ParseDataManager()
		
		menu.onMouseDown = { [weak self] in
			if let wself = self {
				if (wself.menu.iconView?.isSelected == true) {
					Wireframe.showPopover(wself.popover!, fromIcon: wself.menu.iconView!)
				} else {
					Wireframe.hidePopover(wself.popover!)
				}
			}
        }
		
        sleep = SleepNotifications()
        sleep?.computerWentToSleep = {
			ComputerSleepInteractor(data: sharedData).run()
        }
        sleep?.computerWakeUp = {
			ComputerWakeUpInteractor(data: sharedData).runWithLastSleepDate(self.sleep?.lastSleepDate)
        }
	}
	
    func applicationDidFinishLaunching (aNotification: NSNotification) {
		
		let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			self.menu.iconView?.mouseDown(NSEvent())
		})
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
    }
	
    func applicationWillTerminate (aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
	
    func userNotificationCenter (center: NSUserNotificationCenter, shouldPresentNotification notification: NSUserNotification) -> Bool {
        return true
    }
}


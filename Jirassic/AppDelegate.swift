//
//  AppDelegate.swift
//  Jira Logger
//
//  Created by Cristian Baluta on 24/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

var localRepository: Repository!
var remoteRepository: Repository?

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    @IBOutlet var popover: NSPopover?
    var appWireframe = AppWireframe()
    private var sleep: SleepNotifications?
	private let menu = MenuBarController()
	
    class func sharedApp() -> AppDelegate {
        return NSApplication.sharedApplication().delegate as! AppDelegate
    }
    
	override init() {
		super.init()
        
        localRepository = CoreDataRepository()
//		remoteRepository = IcloudRepository()
		
		menu.onMouseDown = { [weak self] in
			if let wself = self {
				if (wself.menu.iconView?.isSelected == true) {
					wself.appWireframe.showPopover(wself.popover!, fromIcon: wself.menu.iconView!)
				} else {
					wself.appWireframe.hidePopover(wself.popover!)
				}
			}
        }
		
        sleep = SleepNotifications()
        sleep?.computerWentToSleep = {
			ComputerSleepInteractor(data: localRepository).run()
        }
        sleep?.computerWakeUp = {
			ComputerWakeUpInteractor(data: localRepository).runWithLastSleepDate(self.sleep?.lastSleepDate)
        }
	}
	
    func applicationDidFinishLaunching (aNotification: NSNotification) {
		
		let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC)))
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			self.menu.iconView?.mouseDown(NSEvent())
		})
        NSUserNotificationCenter.defaultUserNotificationCenter().delegate = self
        
        NSEvent.addGlobalMonitorForEventsMatchingMask(.RightMouseDownMask, handler: { event in
            self.popover?.performClose(nil)
        })
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


//
//  AppDelegate.swift
//  Jira Logger
//
//  Created by Cristian Baluta on 24/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet var window: NSWindow?
    @IBOutlet var popover: NSPopover?
    private var _sleep: SleepNotifications?
	
	override init() {
		
		super.init()
		
		InitParse()
		
		let menu = MenuBarController()
		menu.onMouseDown = {
			if (menu.iconView?.isSelected == true) {
				let icon = menu.iconView!
				let edge = NSMinYEdge
				let rect = icon.frame
				self.popover?.showRelativeToRect(rect, ofView: icon, preferredEdge: edge);
			} else {
				self.popover?.close()
			}
        }
        _sleep = SleepNotifications()
        _sleep?.computerWentToSleep = {
			let existingTasks = sharedData.tasksForDayOnDate(NSDate())
			var scrumExists = false
			for task in existingTasks {
				if task.task_type == TaskType.Scrum.rawValue {
					scrumExists = true
					break
				}
			}
			if !scrumExists {
				sharedData.addScrumSessionTask(NSDate(), dateEnd:nil)
			}
        }
        _sleep?.computerWakeUp = {
			let existingTasks = sharedData.tasksForDayOnDate(NSDate())
			for task in existingTasks {
				task.date_task_finished = NSDate()
				break
			}
        }
	}
	
    func applicationDidFinishLaunching(aNotification: NSNotification) {
		
    }
	
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}


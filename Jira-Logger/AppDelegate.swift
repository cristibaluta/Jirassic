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
	@IBOutlet var popover : NSPopover?
	
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
	}
	
    func applicationDidFinishLaunching(aNotification: NSNotification) {
		
    }
	
    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }
}


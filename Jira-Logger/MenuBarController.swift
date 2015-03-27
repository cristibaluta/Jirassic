//
//  MenuBarController.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 26/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class MenuBarController: NSObject {
	
//	@IBOutlet var statusMenu: NSMenu?
	var statusItem: NSStatusItem?
	
	override init() {
		self.statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(-1)
//		self.statusItem?.menu = self.statusMenu
		self.statusItem?.title = "Jira"
		self.statusItem?.highlightMode = true
		self.statusItem?.action = Selector("handleStatusItemToggle:");
	}
	
	func handleStatusItemToggle(sender: NSStatusItem) {
		println(sender);
	}
	
}

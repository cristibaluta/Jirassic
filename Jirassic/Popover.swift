//
//  Panel.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class Popover: NSPopover {
	
	required init?(coder: NSCoder) {
		super.init()
	}
	
	override func awakeFromNib() {
//		RCLogO(self.contentViewController)
//		RCLogRect(self.contentViewController?.view.frame)
	}
	
	func canBecomeKeyWindow() -> Bool {
		return true; // Allow Search field to become the first responder
	}
}

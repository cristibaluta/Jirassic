//
//  MenuBarController.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 26/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class MenuBarController: NSObject {
	
	var iconView: MenuBarIconView?
	var onMouseDown: (() -> ())?
	
	override init() {
		super.init()
		
		let bar = NSStatusBar.system();
		let length: CGFloat = -1 //NSVariableStatusItemLength
		let item = bar.statusItem(withLength: length);
		
		iconView = MenuBarIconView(item: item)
		iconView?.onMouseDown = {
			self.onMouseDown?()
		}
		item.view = iconView
	}
}

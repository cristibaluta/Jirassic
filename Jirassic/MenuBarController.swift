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
		
		let bar = NSStatusBar.systemStatusBar();
		let length: CGFloat = -1 //NSVariableStatusItemLength
		let item = bar.statusItemWithLength(length);
		
		iconView = MenuBarIconView(imageName: "Status", item: item)
		iconView?.onMouseDown = {
			self.onMouseDown!()
		}
		item.view = iconView
	}
}

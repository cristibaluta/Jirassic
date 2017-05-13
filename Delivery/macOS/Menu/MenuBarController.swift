//
//  MenuBarController.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 26/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class MenuBarController: NSObject {
	
    let bar = NSStatusBar.system()
    var item: NSStatusItem!
	var iconView: MenuBarIconView?
	var onMouseDown: (() -> ())?
    var appearsDisabled: Bool? {
        didSet {
//            item?.button?.appearsDisabled = appearsDisabled!
            item.view?.alphaValue = 0.3
        }
    }
	
	override init() {
		super.init()
		
		let length: CGFloat = -1 //NSVariableStatusItemLength
        item = bar.statusItem(withLength: length)        
//        item.button?.image = NSImage(named: "MenuBarIcon-Normal")!
//        item.button?.alternateImage = NSImage(named: "MenuBarIcon-Selected")!
//        
//        item.menu = NSMenu()
//        item.menu?.delegate = self
		
		iconView = MenuBarIconView(item: item)
		iconView?.onMouseDown = {
			self.onMouseDown?()
		}
		item.view = iconView
        appearsDisabled = true
        
        appearsDisabled = true
	}
    
    func handleQuitButton() {
        NSApplication.shared().terminate(nil)
    }
}
//
//extension MenuBarController: NSMenuDelegate {
//    
//    func menuWillOpen (_ menu: NSMenu) {
//        
//        if NSEvent.pressedMouseButtons() == 1 {
//            onMouseDown?()
//            item?.menu?.cancelTracking()
//        }
//    }
//}

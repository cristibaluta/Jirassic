//
//  MenuBarController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 26/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class MenuBarController: NSObject {
	
    fileprivate let bar = NSStatusBar.system
    fileprivate var item: NSStatusItem!
	var iconView: MenuBarIconView!
    
    var onOpen: (() -> ())?
    var onClose: (() -> ())?
    
    var appearsDisabled: Bool? {
        set {
            iconView.alphaValue = newValue == true ? 0.4 : 1.0
        }
        get {
            return iconView.alphaValue != 1.0
        }
    }
    var isDark: Bool? {
        didSet {
            iconView.isDark = isDark
        }
    }
	
	override init() {
		super.init()
		
		let length: CGFloat = -1 //NSVariableStatusItemLength
        item = bar.statusItem(withLength: length)
		
		iconView = MenuBarIconView(item: item)
		iconView.onMouseDown = {
            if self.iconView.isSelected {
                self.onOpen?()
            } else {
                self.onClose?()
            }
		}
		item.view = iconView
	}
    
    func handleQuitButton() {
        NSApplication.shared.terminate(nil)
    }
    
    func triggerOpen() {
        if iconView.isSelected == false {
            iconView.mouseDown(with: NSEvent())
        }
    }
    
    func triggerClose() {
        if iconView.isSelected == true {
            iconView.mouseDown(with: NSEvent())
        }
    }
}

//
//  IconView.swift
//  SwiftStatusBarApplication
//
//  Created by Tommy Leung on 6/7/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Cocoa

class MenuBarIconView : NSView {
	
    fileprivate(set) var image: NSImage
    fileprivate let item: NSStatusItem
    
    var onMouseDown: (() -> ())?
    
    var _isSelected = false
    var isSelected: Bool {
        get {
            return _isSelected
        }
        set {
            _isSelected = newValue
            self.image = NSImage(named: NSImage.Name(rawValue: isDark == true || _isSelected ? "MenuBarIcon-Selected" : "MenuBarIcon-Normal"))!
            self.needsDisplay = true
        }
    }
    var isDark: Bool? {
        didSet {
            self.image = NSImage(named: NSImage.Name(rawValue: isDark == true ? "MenuBarIcon-Selected" : "MenuBarIcon-Normal"))!
            self.needsDisplay = true
        }
    }
    
    init (item: NSStatusItem) {
        
        self.item = item
        self.image = NSImage(named: NSImage.Name(rawValue: "MenuBarIcon-Normal"))!
        
        let thickness = NSStatusBar.system.thickness
        let rect = CGRect(x: 0, y: 0, width: thickness, height: thickness)
        
        super.init(frame: rect)
    }

    required init? (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw (_ dirtyRect: NSRect) {
		
        self.item.drawStatusBarBackground(in: dirtyRect, withHighlight: self.isSelected)
        
        let size = self.image.size
        let rect = CGRect(x: 2, y: 2, width: size.width, height: size.height)
        
        image.draw(in: rect)
    }
    
    override func mouseDown (with theEvent: NSEvent) {
        self.isSelected = !_isSelected
        onMouseDown?()
    }
    
    override func mouseUp (with theEvent: NSEvent) {
		
    }
}

//
//  IconView.swift
//  SwiftStatusBarApplication
//
//  Created by Tommy Leung on 6/7/14.
//  Copyright (c) 2014 Tommy Leung. All rights reserved.
//

import Cocoa

class MenuBarIconView : NSView {
	
    private(set) var image: NSImage
    private let item: NSStatusItem
    
    var onMouseDown: () -> ()
    
    var isSelected: Bool {
		
        didSet {
            //redraw if isSelected changes for bg highlight
            if (isSelected != oldValue) {
                self.needsDisplay = true
            }
        }
    }
    
    init (imageName: String, item: NSStatusItem) {
		
        self.image = NSImage(named: imageName)!
        self.item = item
        self.isSelected = false
        self.onMouseDown = {}
        
        let thickness = NSStatusBar.systemStatusBar().thickness
        let rect = CGRectMake(0, 0, thickness, thickness)
        
        super.init(frame: rect)
    }

    required init? (coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect (dirtyRect: NSRect) {
		
        self.item.drawStatusBarBackgroundInRect(dirtyRect, withHighlight: self.isSelected)
        
        let size = self.image.size
        let rect = CGRectMake(2, 2, size.width, size.height)
        
        self.image.drawInRect(rect)
    }
    
    override func mouseDown (theEvent: NSEvent) {
        self.isSelected = !self.isSelected;
        self.onMouseDown();
    }
    
    override func mouseUp (theEvent: NSEvent) {
		
    }
}

//
//  TimeBox.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/03/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class TimeBox: NSBox {
    
    internal var timeTextField: NSTextField?
    
    var stringValue: String {
        get {
            return timeTextField!.stringValue
        }
        set {
            timeTextField!.stringValue = newValue
        }
    }
    var isDark: Bool = false {
        didSet {
            let isDark = self.isDark
            if #available(OSX 10.14, *) {
                self.fillColor = isDark ? NSColor.white : NSColor.darkGray
                self.timeTextField?.textColor = isDark ? NSColor.darkGray : NSColor.white
            } else {
                self.fillColor = isDark ? NSColor.darkGray : NSColor.white
//                self.borderColor = isDark ? NSColor.clear : NSColor.white
                self.timeTextField?.textColor = isDark ? NSColor.white : NSColor.darkGray
//                self.timeTextField?.backgroundColor = isDark ? NSColor.darkGray : NSColor.darkGray
            }
        }
    }
    var onClick: (() -> Void)?
    
    init() {
        super.init(frame: NSRect.zero)
        stringValue = ""
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.borderType = .noBorder
        
        timeTextField = NSTextField()
        timeTextField?.font = NSFont.boldSystemFont(ofSize: 10)
        timeTextField?.textColor = NSColor.darkGray
        timeTextField?.backgroundColor = NSColor.clear
        timeTextField?.drawsBackground = false
        timeTextField?.alignment = .center
        timeTextField?.focusRingType = .none
        timeTextField?.placeholderString = "00:00"
        timeTextField?.isEnabled = false
        timeTextField?.isEditable = false
        
        self.addSubview(timeTextField!)

        timeTextField?.translatesAutoresizingMaskIntoConstraints = false
        let viewsDictionary = ["view": timeTextField!]
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(-5)-[view]-(-5)-|", options: [], metrics: nil, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(-3)-[view]-(-5)-|", options: [], metrics: nil, views: viewsDictionary))
    }
    
    override func mouseDown(with event: NSEvent) {
        onClick?()
    }
    
    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        
        let trackingArea = NSTrackingArea(rect: NSZeroRect,
                                          options: [
                                            NSTrackingArea.Options.inVisibleRect,
                                            NSTrackingArea.Options.activeAlways,
                                            NSTrackingArea.Options.mouseEnteredAndExited
            ],
                                          owner: self,
                                          userInfo: nil)
        if !self.trackingAreas.contains(trackingArea) {
            self.addTrackingArea(trackingArea)
        }
    }
}

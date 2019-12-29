//
//  TimeBox.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/03/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class TimeBox: NSBox {
    
    internal var backgroundBox: NSBox?
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
//                self.fillColor = .clear //isDark ? .white : .darkGray
                self.timeTextField?.textColor = .labelColor //isDark ? .darkGray : .white
            } else {
//                self.fillColor = isDark ? NSColor.darkGray : NSColor.white
//                self.borderColor = isDark ? NSColor.clear : NSColor.white
                self.timeTextField?.textColor = isDark ? NSColor.white : NSColor.darkGray
//                self.timeTextField?.backgroundColor = isDark ? NSColor.darkGray : NSColor.darkGray
            }
        }
    }
    var onClick: (() -> Void)?
    
    init() {
        super.init(frame: NSRect.zero)
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.clear.cgColor
        stringValue = ""
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundBox = NSBox()
        backgroundBox?.borderType = .noBorder
        backgroundBox?.cornerRadius = 7
        backgroundBox?.boxType = .custom
        backgroundBox?.fillColor = .clear
//        self.addSubview(backgroundBox!)
//        backgroundBox?.constrainToSuperview()
        
        timeTextField = NSTextField()
        timeTextField?.font = NSFont.systemFont(ofSize: 10)
        timeTextField?.textColor = .darkGray
        timeTextField?.backgroundColor = .clear
//        timeTextField?.drawsBackground = false
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
            withVisualFormat: "V:|-(-3)-[view]-(-6)-|", options: [], metrics: nil, views: viewsDictionary))
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

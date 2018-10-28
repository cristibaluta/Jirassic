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
    
    var isEditable: Bool = true {
        didSet {
            timeTextField?.isEditable = isEditable
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
        
        self.borderType = .lineBorder//.noBorder
        self.borderColor = NSColor.white
        self.fillColor = NSColor.white
        
        timeTextField = NSTextField()
        timeTextField?.font = NSFont.boldSystemFont(ofSize: 10)
        timeTextField?.textColor = NSColor.darkGray//AppDelegate.sharedApp().theme.textColor
        timeTextField?.backgroundColor = NSColor.white
        timeTextField?.drawsBackground = true
        timeTextField?.alignment = .center
        timeTextField?.focusRingType = .none
        timeTextField?.placeholderString = "00:00"
        timeTextField?.isEnabled = false
        
        self.addSubview(timeTextField!)

        timeTextField?.translatesAutoresizingMaskIntoConstraints = false
        let viewsDictionary = ["view": timeTextField!]
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(-5)-[view]-(-5)-|", options: [], metrics: nil, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(-3)-[view]-(-5)-|", options: [], metrics: nil, views: viewsDictionary))
    }
    
    override func mouseDown(with event: NSEvent) {
        if isEditable {
            onClick?()
        }
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

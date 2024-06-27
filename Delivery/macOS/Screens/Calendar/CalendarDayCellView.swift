//
//  CalendarDayView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa

class CalendarDayCellView: NSView {
    
    private var dayText: NSTextField
    private var weekdayText: NSTextField
    private var bulletText: NSTextField
    private var backgroundView: NSBox
    
    override init(frame frameRect: NSRect) {
        
        let w = frameRect.size.width
        let h = frameRect.size.height
        
        backgroundView = NSBox(frame: NSRect(x: 0, y: 0, width: w, height: h))
        backgroundView.boxType = .custom
        backgroundView.borderType = .noBorder
        backgroundView.cornerRadius = 10
        backgroundView.fillColor = .darkGray
        
        dayText = NSTextField(frame: NSRect(x: -4, y: 0, width: w+8, height: w))
        dayText.font = NSFont.boldSystemFont(ofSize: 11)
        dayText.alignment = .center
        dayText.backgroundColor = NSColor.clear
        dayText.isBordered = false
        dayText.isEditable = false
        
        weekdayText = NSTextField(frame: NSRect(x: 0, y: w, width: w, height: w))
        weekdayText.font = NSFont.boldSystemFont(ofSize: 11)
        weekdayText.alignment = .center
        weekdayText.backgroundColor = NSColor.clear
        weekdayText.isBordered = false
        weekdayText.isEditable = false
        
        bulletText = NSTextField(frame: NSRect(x: 0, y: -10, width: w, height: w))
        bulletText.font = NSFont.boldSystemFont(ofSize: 11)
        bulletText.alignment = .center
        bulletText.backgroundColor = NSColor.clear
        bulletText.isBordered = false
        bulletText.isEditable = false
        
        super.init(frame: frameRect)
        self.addSubview(backgroundView)
        self.addSubview(dayText)
        self.addSubview(weekdayText)
        self.addSubview(bulletText)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var day: Int = 0 {
        didSet {
            dayText.stringValue = "\(day)"
        }
    }
    
    var weekday: String = "" {
        didSet {
            weekdayText.stringValue = weekday
        }
    }
    
    var isSelected: Bool = false {
        didSet {
//            backgroundView.isHidden = !isSelected
            backgroundView.fillColor = isSelected ? .darkGray : .clear
            dayText.textColor = isSelected ? .white : .labelColor
            weekdayText.textColor = isSelected ? .white : .labelColor
        }
    }
    
    var isStarted: Bool = false {
        didSet {
            dayText.alphaValue = isStarted ? 1.0 : 0.2
            weekdayText.alphaValue = isStarted ? 1.0 : 0.2
        }
    }
    
    var isToday: Bool = false {
        didSet {
            backgroundView.borderType = isToday ? .lineBorder : .noBorder
        }
    }
    
    var isEnded: Bool = false {
        didSet {
            bulletText.stringValue = isEnded ? "•" : ""
        }
    }
    
    var onClick: (() -> Void)?
    
    override func mouseDown(with event: NSEvent) {
        onClick?()
    }
}

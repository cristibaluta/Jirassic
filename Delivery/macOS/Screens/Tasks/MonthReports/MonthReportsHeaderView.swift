//
//  MonthReportsHeaderView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class MonthReportsHeaderView: ReportsHeaderView {
    
    private let butCopyAll: NSButton
    private var totalDaysTextField: NSTextField
    var didCopyAll: (() -> Void)?
    
    var numberOfDays: Int {
        get {
            return 0
        }
        set {
            totalDaysTextField.stringValue = "Number of days: \(newValue)"
        }
    }
    
    override init(height: CGFloat) {
        
        butCopyAll = NSButton()
        butCopyAll.frame = NSRect(x: 15, y: 60, width: 80, height: 20)
        butCopyAll.setButtonType(.momentaryPushIn)
        butCopyAll.bezelStyle = .texturedRounded
        butCopyAll.title = "Copy all"
        butCopyAll.toolTip = "Copy all reports to clipboard."
        
        totalDaysTextField = NSTextField()
        totalDaysTextField.alignment = NSTextAlignment.right
        totalDaysTextField.drawsBackground = false
        totalDaysTextField.isBordered = false
        totalDaysTextField.isEnabled = false
        totalDaysTextField.focusRingType = .none
        totalDaysTextField.textColor = NSColor.white
        totalDaysTextField.backgroundColor = NSColor.clear
        
        super.init(height: height)
        
        butCopyAll.target = self
        butCopyAll.action = #selector(self.handleCopyAllButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        self.addSubview(butCopyAll)
        
        totalDaysTextField.frame = NSRect(x: dirtyRect.size.width - 216, y: 60, width: 200, height: 20)
        self.addSubview(totalDaysTextField)
    }
}

extension MonthReportsHeaderView {
    
    @objc func handleCopyAllButton (_ sender: NSButton) {
        didCopyAll?()
    }
}

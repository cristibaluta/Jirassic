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
    private var butCopyAsHtml: NSButton
    private var totalDaysTextField: NSTextField
    var didClickCopyAll: ((Bool) -> Void)?
    
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
        
        butCopyAsHtml = NSButton()
        butCopyAsHtml.frame = NSRect(x: 110, y: 60, width: 100, height: 20)
        butCopyAsHtml.setButtonType(.switch)
        
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
        butCopyAsHtml.attributedTitle = NSAttributedString(string: "Copy as html", attributes: attributes)
        butCopyAsHtml.target = self
        butCopyAsHtml.action = #selector(self.handleHtmlButton)
        butCopyAsHtml.state = pref.bool(.copyWorklogsAsHtml) ? .on : .off
        
        self.addSubview(butCopyAll)
        self.addSubview(butCopyAsHtml)
        self.addSubview(totalDaysTextField)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        totalDaysTextField.frame = NSRect(x: dirtyRect.size.width - 216, y: 60, width: 200, height: 20)
    }
}

extension MonthReportsHeaderView {
    
    @objc func handleCopyAllButton (_ sender: NSButton) {
        didClickCopyAll?(pref.bool(.copyWorklogsAsHtml))
    }
    
    @objc func handleHtmlButton (_ sender: NSButton) {
        pref.set(sender.state == .on, forKey: .copyWorklogsAsHtml)
    }
}

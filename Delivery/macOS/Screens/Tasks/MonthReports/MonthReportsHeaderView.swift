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
    var didCopyAll: (() -> Void)?
    
    override init() {
        
        butCopyAll = NSButton()
        butCopyAll.frame = NSRect(x: 15, y: 40, width: 100, height: 20)
        butCopyAll.setButtonType(.momentaryPushIn)
        butCopyAll.bezelStyle = .texturedRounded
        butCopyAll.title = "Copy all"
        butCopyAll.toolTip = "Copy all reports to clipboard."
        
        super.init()
        
        butCopyAll.target = self
        butCopyAll.action = #selector(self.handleCopyAllButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        self.addSubview(butCopyAll)
    }
}

extension MonthReportsHeaderView {
    @objc func handleCopyAllButton (_ sender: NSButton) {
        didCopyAll?()
    }
}

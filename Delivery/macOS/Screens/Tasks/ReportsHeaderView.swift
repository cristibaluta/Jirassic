//
//  ReportsHeaderView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class ReportsHeaderView: NSTableHeaderView {
    
    fileprivate var butRound: NSButton
    fileprivate var butPercents: NSButton
    fileprivate let settings = InternalSettings()
    var didChangeSettings: (() -> ())?
    
    init() {
        
        butRound = NSButton()
        butRound.frame = NSRect(x: 200, y: 20, width: 200, height: 20)
        butRound.attributedTitle = NSAttributedString(string: "Round to 8 hours", attributes: [ NSForegroundColorAttributeName : NSColor.white])
        butRound.setButtonType(NSSwitchButton)
        butRound.state = settings.roundDay ? NSOnState : NSOffState
        
        butPercents = NSButton()
        butPercents.frame = NSRect(x: 15, y: 20, width: 200, height: 20)
        butPercents.attributedTitle = NSAttributedString(string: "Show time in percents", attributes: [ NSForegroundColorAttributeName : NSColor.white])
        butPercents.setButtonType(NSSwitchButton)
        butPercents.state = settings.usePercents ? NSOnState : NSOffState
        
        super.init(frame: NSRect(x: 0, y: 0, width: 0, height: 60))
        
        butRound.target = self
        butRound.action = #selector(self.handleRoundButton)
        butPercents.target = self
        butPercents.action = #selector(self.handlePercentsButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.darkGray.set()
        NSRectFill(dirtyRect)
        
        self.addSubview(butPercents)
        self.addSubview(butRound)
    }
}

extension ReportsHeaderView {
    
    func handleRoundButton (_ sender: NSButton) {
        settings.roundDay = sender.state == NSOnState
        didChangeSettings?()
    }
    
    func handlePercentsButton (_ sender: NSButton) {
        settings.usePercents = sender.state == NSOnState
        didChangeSettings?()
    }
}

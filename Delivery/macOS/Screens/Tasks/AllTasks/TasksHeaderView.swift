//
//  TasksHeaderView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 21/11/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class TasksHeaderView: NSTableHeaderView {
    
    private var butAddTask: NSButton
    private var butCloseDay: NSButton
    private var butJira: NSButton
    private var butJiraSetup: NSButton
    
    private unowned let appWireframe = AppDelegate.sharedApp().appWireframe
    private var store = Store.shared
    private var moduleJira = ModuleJiraTempo()
    private let pref = RCPreferences<LocalPreferences>()
    var didAddTask: (() -> Void)?
    var didCloseDay: ((_ shouldSavetoJira: Bool) -> Void)?
    var isDayEnded: Bool = false {
        didSet {
            self.butAddTask.isHidden = isDayEnded
            self.butCloseDay.isHidden = isDayEnded
            self.butJira.isHidden = isDayEnded
            self.butJiraSetup.isHidden = !isDayEnded
        }
    }
    
    init (height: CGFloat) {
        
        butAddTask = NSButton()
        butAddTask.frame = NSRect(x: 15, y: 20, width: 200, height: 20)
//        butAddTask.attributedTitle = NSAttributedString(string: "Show time in percents", attributes: attributes)
        butAddTask.setButtonType(.switch)
        butAddTask.state = pref.bool(.usePercents) ? NSControl.StateValue.on : NSControl.StateValue.off
        
        butCloseDay = NSButton()
        
        butJira = NSButton()
        
        butJiraSetup = NSButton()
        butJiraSetup.frame = NSRect(x: 200, y: 20, width: 200, height: 20)
        butJiraSetup.setButtonType(.switch)
        butJiraSetup.state = pref.bool(.enableRoundingDay) ? .on : .off
        butJiraSetup.toolTip = "This can be set in 'Settings/Tracking/Working between'"
        
        super.init(frame: NSRect(x: 0, y: 0, width: 0, height: height))
        
        butAddTask.target = self
        butAddTask.action = #selector(self.handleAddButton)
        butJiraSetup.target = self
        butJiraSetup.action = #selector(self.handleJiraButton)
        
        self.addSubview(butAddTask)
        self.addSubview(butCloseDay)
        self.addSubview(butJira)
        self.addSubview(butJiraSetup)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.darkGray.set()
        dirtyRect.fill()
    }
    
    private func setupJiraButton() {
        let available = store.isJiraTempoPurchased && moduleJira.isConfigured && moduleJira.isProjectConfigured
        let enabled = available && pref.bool(.enableJira)
        butJira.isEnabled = available
        butJira.state = enabled ? .on : .off
        butJiraSetup.isHidden = available
    }
    
    private func enableJira (_ enabled: Bool) {
        pref.set(enabled, forKey: .enableJira)
    }
}

extension TasksHeaderView {
    
    @IBAction func handleAddButton (_ sender: NSButton) {
        didAddTask?()
    }
    
    @objc func handleWorklogsButton (_ sender: NSButton) {
        didCloseDay?(true)
    }
    
    @objc func handleCloseDayButton (_ sender: NSButton) {
        didCloseDay?(butJira.state == .on)
    }
    
    @objc func handleJiraButton (_ sender: NSButton) {
        enableJira(sender.state == .on)
    }
    
    @objc func handleJiraSetupButton (_ sender: NSButton) {
        pref.set(SettingsTab.output.rawValue, forKey: .settingsActiveTab)
        appWireframe.flipToSettingsController()
    }
}

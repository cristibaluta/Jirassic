//
//  FooterCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class TasksHeaderView: NSTableHeaderView {

    @IBOutlet private var butAdd: NSButton!
    @IBOutlet private var butCloseDay: NSButton!
    @IBOutlet private var butWorklogs: NSButton!
    @IBOutlet private var butJiraSetup: NSButton!

    private unowned let appWireframe = AppDelegate.sharedApp().appWireframe
    private var store = Store.shared
    private var moduleJira = ModuleJiraTempo()
    private let pref = RCPreferences<LocalPreferences>()
    var didClickAddTask: (() -> Void)?
    var didClickCloseDay: (() -> Void)?
    var didClickSaveWorklogs: (() -> Void)?
    var isDayEnded: Bool = false {
        didSet {
            let isJiraAvailable = store.isJiraTempoPurchased && moduleJira.isConfigured && moduleJira.isProjectConfigured
            self.butAdd.isHidden = isDayEnded
            self.butCloseDay.isHidden = isDayEnded
            self.butWorklogs.isHidden = !isDayEnded
            self.butWorklogs.isEnabled = isJiraAvailable
            self.butJiraSetup.isHidden = isDayEnded ? isJiraAvailable : true
        }
    }
    
    override func headerRect(ofColumn column: Int) -> NSRect {
        // This will prevent for a label to appear  in the middle of the header
        return NSRect.zero
    }
    
//    override func draw (_ dirtyRect: NSRect) {
//        if #available(OSX 10.14, *) {
//            // This version of osx has a nice blurry background
//            super.draw(dirtyRect)
//        } else {
//            // Previous versions of osx have transparent background
//            NSColor.white.set()
//            dirtyRect.fill()
//        }
//    }
    
    @IBAction func handleAddButton (_ sender: NSButton) {
        didClickAddTask?()
    }
    
    @IBAction func handleCloseDayButton (_ sender: NSButton) {
        didClickCloseDay?()
    }
    
    @IBAction func handleWorklogsButton (_ sender: NSButton) {
        didClickSaveWorklogs?()
    }
    
    @IBAction func handleJiraSetupButton (_ sender: NSButton) {
        pref.set(SettingsTab.output.rawValue, forKey: .settingsActiveTab)
        appWireframe.flipToSettingsController()
    }

}

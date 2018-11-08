//
//  FooterCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/01/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class FooterCell: NSTableRowView {

    @IBOutlet private var butAdd: NSButton!
    @IBOutlet private var butWorklogs: NSButton!
    @IBOutlet private var closeDayView: NSView!
    @IBOutlet private var butCloseDay: NSButton!
    @IBOutlet private var butJira: NSButton!
    @IBOutlet private var butJiraSetup: NSButton!

    private unowned let appWireframe = AppDelegate.sharedApp().appWireframe
    private var store = Store.shared
    private var moduleJira = ModuleJiraTempo()
    private let pref = RCPreferences<LocalPreferences>()
    var didAddTask: (() -> Void)?
    var didCloseDay: ((_ shouldSavetoJira: Bool) -> Void)?
    var isDayEnded: Bool? {
        didSet {
            self.butAdd.isHidden = isDayEnded!
            self.closeDayView.isHidden = isDayEnded!
            self.butWorklogs.isHidden = !isDayEnded!
        }
    }
    
    override func draw (_ dirtyRect: NSRect) {
        NSColor.clear.set()
        dirtyRect.fill()
    }
    
    @IBAction func handleAddButton (_ sender: NSButton) {
        didAddTask?()
    }
    
    @IBAction func handleWorklogsButton (_ sender: NSButton) {
        didCloseDay?(true)
    }
    
    @IBAction func handleCloseDayButton (_ sender: NSButton) {
        didCloseDay?(butJira.state == .on)
    }
    
    @IBAction func handleJiraButton (_ sender: NSButton) {
        enableJira(sender.state == .on)
    }
    
    @IBAction func handleJiraSetupButton (_ sender: NSButton) {
        pref.set(SettingsTab.output.rawValue, forKey: .settingsActiveTab)
        appWireframe.flipToSettingsController()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupJiraButton()
    }
    
    private func setupJiraButton() {
        let available = store.isJiraTempoPurchased && moduleJira.isReachable
        let enabled = available && pref.bool(.enableJira)
        butJira.isEnabled = available
        butJira.state = enabled ? .on : .off
        butJiraSetup.isHidden = available
    }

    private func enableJira (_ enabled: Bool) {
        pref.set(enabled, forKey: .enableJira)
    }

}

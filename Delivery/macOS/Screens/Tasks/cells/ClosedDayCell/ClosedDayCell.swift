//
//  ClosedDayCell.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa
import RCPreferences

class ClosedDayCell: NSTableRowView {
    
    @IBOutlet private var butSaveWorklogs: NSButton!
    @IBOutlet private var butSetupJira: NSButton!
    
    private unowned let appWireframe = AppDelegate.sharedApp().appWireframe
    private var store = Store.shared
    private var moduleJira = ModuleJiraTempo()
    private let pref = RCPreferences<LocalPreferences>()
    
    var didClickSaveWorklogs: (() -> Void)?
    var didClickSetupJira: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let isJiraAvailable = store.isJiraTempoPurchased &&
            moduleJira.isConfigured &&
            moduleJira.isProjectConfigured
        butSaveWorklogs.isEnabled = isJiraAvailable
        butSetupJira.isHidden = isJiraAvailable
    }
    
    @IBAction func handleSaveWorklogsButton (_ sender: NSButton) {
        didClickSaveWorklogs?()
    }
    
    @IBAction func handleSetupJiraButton (_ sender: NSButton) {
        didClickSetupJira?()
    }
    
}

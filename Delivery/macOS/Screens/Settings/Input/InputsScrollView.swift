//
//  InputsScrollView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class InputsScrollView: NSScrollView {
    
    @IBOutlet fileprivate var tableView: NSTableView!
    var dataSource: InputsTableViewDataSource?// If not declared, the reference is released
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.selectionHighlightStyle = .none
        tableView.backgroundColor = .clear
        tableView.intercellSpacing = NSSize(width: 0, height: 30)
        
        dataSource = InputsTableViewDataSource(tableView: tableView)
        tableView.dataSource = dataSource
        tableView.delegate = dataSource
        
        tableView.reloadData()
    }

    func showSettings (_ settings: SettingsBrowser) {
        dataSource!.showSettingsBrowser(settings)
    }

    func settings() -> SettingsBrowser {
        return dataSource!.settingsBrowser()
    }
    
    func save() {
        dataSource?.shellCell?.save()
        dataSource?.jitCell?.save()
        dataSource?.gitCell?.save()
        dataSource?.browserCell?.save()
        dataSource?.calendarCell?.save()
    }
    
    func setShellStatus (available: Bool, compatible: Bool) {
        dataSource?.shellCell?.setShellStatus (available: available, compatible: compatible)
    }
    
    func setJirassicStatus (available: Bool, compatible: Bool) {
        dataSource?.jirassicCell?.setJirassicStatus (available: available, compatible: compatible)
    }
    
    func setJitStatus (available: Bool, compatible: Bool) {
        dataSource?.jitCell?.setJitStatus (available: available, compatible: compatible)
    }
    
    func setGitStatus (available: Bool) {
        dataSource?.gitCell?.presenter.isShellScriptInstalled = available
    }
    
    func setBrowserStatus (available: Bool, compatible: Bool) {
        dataSource?.browserCell?.setBrowserStatus (available: available, compatible: compatible)
    }
}

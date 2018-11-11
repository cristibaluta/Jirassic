//
//  InputsScrollView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class InputsScrollView: NSScrollView {
    
    @IBOutlet private var tableView: NSTableView!
    var dataSource: InputsTableViewDataSource?// If not declared, the reference is released
    var onPurchasePressed: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableView.selectionHighlightStyle = .none
        tableView.backgroundColor = .clear
        tableView.intercellSpacing = NSSize(width: 0, height: 30)
        
        dataSource = InputsTableViewDataSource(tableView: tableView)
        dataSource?.onPurchasePressed = { [weak self] in
            self?.onPurchasePressed?()
        }
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
    
    func setShellStatus (compatibility: Compatibility) {
        dataSource?.shellCell?.setShellStatus (compatibility: compatibility)
    }
    
    func setJirassicStatus (compatibility: Compatibility) {
        dataSource?.jirassicCell?.setJirassicStatus (compatibility: compatibility)
    }
    
    func setJitStatus (compatibility: Compatibility) {
        dataSource?.jitCell?.setJitStatus (compatibility: compatibility)
    }
    
    func setGitStatus (available: Bool) {
        dataSource?.gitCell?.presenter.isShellScriptInstalled = available
    }
    
    func setBrowserStatus (compatibility: Compatibility) {
        dataSource?.browserCell?.setBrowserStatus (compatibility: compatibility)
    }
}

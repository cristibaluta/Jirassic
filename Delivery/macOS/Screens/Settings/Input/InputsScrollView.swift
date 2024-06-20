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
    var dataSource: InputsTableViewDataSource?// If not declared, the instance is released
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
        dataSource!.browserSettings = settings
    }

    func settings() -> SettingsBrowser {
        return dataSource!.browserSettings!
    }
    
    func save() {
//        dataSource?.shellCell.save()
//        dataSource?.jitCell.save()
//        dataSource?.gitCell.save()
//        dataSource?.browserCell.save()
//        dataSource?.calendarCell.save()
    }
    
    func setShellStatus (compatibility: Compatibility) {
        dataSource?.shellCompatibility = compatibility
    }
    
    func setJirassicStatus (compatibility: Compatibility) {
        dataSource?.jirassicCompatibility = compatibility
    }
    
    func setJitStatus (compatibility: Compatibility) {
        dataSource?.jitCompatibility = compatibility
    }
    
    func setGitStatus (available: Bool) {
        dataSource?.gitAvailable = available
    }
    
    func setBrowserStatus (compatibility: Compatibility) {
        dataSource?.browserCompatibility = compatibility
    }
}

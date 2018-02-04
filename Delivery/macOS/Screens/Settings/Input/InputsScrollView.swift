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
    
    func setJirassicStatus (compatible: Bool, scriptInstalled: Bool) {
        dataSource?.shellCell?.setJirassicStatus (compatible: compatible, scriptInstalled: scriptInstalled)
    }
    
    func setJitStatus (compatible: Bool, scriptInstalled: Bool) {
        dataSource?.jitCell?.setJitStatus (compatible: compatible, scriptInstalled: scriptInstalled)
    }
    
    func setBrowserStatus (compatible: Bool, scriptInstalled: Bool) {
        dataSource?.browserCell?.setBrowserStatus (compatible: compatible, scriptInstalled: scriptInstalled)
    }
}

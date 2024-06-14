//
//  GitUsersViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 16/12/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class GitUsersViewController: NSViewController {
    
    @IBOutlet private weak var scrollView: NSScrollView!
    @IBOutlet private weak var tableView: NSTableView!
    @IBOutlet private weak var doneButton: NSButton!
    
    private let gitModule = ModuleGitLogs()
    private var gitUsers: [GitUser] = []
    var selectedUsers: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    var onDone: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gitModule.fetchUsers { [weak self] users in
            self?.gitUsers = users
            self?.tableView.reloadData()
        }
        tableView.headerView = nil
    }
    
    @IBAction func handleDoneButton(_ sender: NSButton) {
        onDone?()
    }
}

extension GitUsersViewController: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return gitUsers.count
    }
}

extension GitUsersViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        let user = gitUsers[row]
        
        if (tableColumn?.identifier)?.rawValue == "isSelected" {
            let isSelected = selectedUsers.contains(user.email)
            return NSNumber(booleanLiteral: isSelected)
        }
        if (tableColumn?.identifier)?.rawValue == "email" {
            return user.email
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        
        let user = gitUsers[row]
        
        if (tableColumn?.identifier)?.rawValue == "isSelected" {
            guard let isSelected = (object as? NSNumber)?.boolValue else {
                return
            }
            if isSelected {
                selectedUsers.append(user.email)
            } else {
                selectedUsers = selectedUsers.filter({$0 != user.email})
            }
        }
    }
}

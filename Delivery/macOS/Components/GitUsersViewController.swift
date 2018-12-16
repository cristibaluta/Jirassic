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
    
    var onDone: (() -> Void)?
    
    private let pref = RCPreferences<LocalPreferences>()
    private let gitModule = ModuleGitLogs()
    private var users: [GitUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gitModule.fetchUsers { [weak self] users in
            self?.users = users
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func handleDoneButton(_ sender: NSButton) {
        onDone?()
    }
}

extension GitUsersViewController: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return users.count
    }
}

extension GitUsersViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        let user = users[row]
        
        if (tableColumn?.identifier)?.rawValue == "isSelected" {
            let allowedAuthors: [String] = pref.string(.settingsGitAuthors).split(separator: ",").map { String($0) }
            let isSelected = allowedAuthors.contains(user.email)
            return NSNumber(booleanLiteral: isSelected)
        }
        if (tableColumn?.identifier)?.rawValue == "email" {
            return user.email
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        
        let user = users[row]
        
        if (tableColumn?.identifier)?.rawValue == "isSelected" {
            var allowedAuthors: [String] = pref.string(.settingsGitAuthors).split(separator: ",").map { String($0) }
            guard let isSelected = (object as? NSNumber)?.boolValue else {
                return
            }
            if isSelected {
                allowedAuthors.append(user.email)
            } else {
                allowedAuthors = allowedAuthors.filter({$0 != user.email})
            }
            pref.set(allowedAuthors.joined(separator: ","), forKey: .settingsGitAuthors)
        }
    }
}

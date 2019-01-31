//
//  ProjectsViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 20/12/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class ProjectsViewController: NSViewController {
    @IBOutlet private weak var scrollView: NSScrollView!
    @IBOutlet private weak var tableView: NSTableView!
    var projects = ["Bosch Ebike", "Electric castle"]
}

extension ProjectsViewController: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return projects.count
    }
}

extension ProjectsViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        if (tableColumn?.identifier)?.rawValue == "isSelected" {
            return nil
        }
        if (tableColumn?.identifier)?.rawValue == "name" {
            return projects[row]
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        
        if (tableColumn?.identifier)?.rawValue == "isSelected" {
            
        }
    }
}

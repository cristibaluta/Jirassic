//
//  ProjectsListViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 28/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa

class ProjectsListViewController: NSViewController {
    
    @IBOutlet private weak var scrollView: NSScrollView!
    @IBOutlet private weak var tableView: NSTableView!
    @IBOutlet private weak var butAdd: NSButton!
    @IBOutlet private weak var butRemove: NSButton!
    
    private var selectedProject: Project?
    
    var projects = [Project]() {
        didSet {
            tableView.reloadData()
        }
    }
    var didSelectProject: ((Project) -> Void)?
    var didSelectAddProject: (() -> Void)?
    var didSelectRemoveProject: ((Project) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.focusRingType = .none
        tableView.focusRingType = .none
    }
    
    @IBAction func handleAddButton (_ sender: NSButton) {
        didSelectAddProject?()
    }
    
    @IBAction func handleRemoveButton (_ sender: NSButton) {
        guard let project = selectedProject else {
            return
        }
        didSelectRemoveProject?(project)
    }
}

extension ProjectsListViewController: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return projects.count
    }
}

extension ProjectsListViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        
        let project = projects[row]
        if (tableColumn?.identifier)?.rawValue == "isSelected" {
            return nil
        }
        if (tableColumn?.identifier)?.rawValue == "name" {
            return project.title
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        
        if (tableColumn?.identifier)?.rawValue == "isSelected" {
            
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        selectedProject = projects[row]
        didSelectProject?(projects[row])
        return true
    }
}

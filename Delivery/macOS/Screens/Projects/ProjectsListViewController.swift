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
    
//    private var selectedProject: Project?
    
    var projects = [Project]() {
        didSet {
            tableView.reloadData()
        }
    }
    var didSelectProject: ((Project) -> Void)?
    var didUpdateProject: ((Project) -> Void)?
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
    
    func selectProject (_ project: Project) {
        for i in 0...projects.count {
            if projects[i].objectId == project.objectId {
                let indexSet = IndexSet(integer: i)
                tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
                break
            }
        }
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
        if (tableColumn?.identifier)?.rawValue == "name" {
            return project.title
        }
        return nil
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        
        if (tableColumn?.identifier)?.rawValue == "name" {
            projects[row].title = object as? String ?? ""
            didUpdateProject?(projects[row])
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
//        selectedProject = projects[row]
        didSelectProject?(projects[row])
        return true
    }
}

//
//  DataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

protocol TasksAndReportsDataSource {

    var tableView: NSTableView! {get set}

    func addTask (_ task: Task, at row: Int)
    func removeTask (at row: Int)
    // Used by tasks
    var didClickAddRow: ((_ row: Int) -> Void)? {get set}
    var didClickRemoveRow: ((_ row: Int) -> Void)? {get set}
    var didClickCloseDay: ((_ tasks: [Task]) -> Void)? {get set}
    var didClickSaveWorklogs: (() -> Void)? {get set}
    var didClickSetupJira: (() -> Void)? {get set}
    // Used by reports
    var didClickCopyMonthlyReport: ((_ asHtml: Bool) -> Void)? {get set}
    var didChangeSettings: (() -> Void)? {get set}
}

typealias DataSource = NSTableViewDataSource & NSTableViewDelegate & TasksAndReportsDataSource

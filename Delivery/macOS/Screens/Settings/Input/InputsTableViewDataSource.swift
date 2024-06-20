//
//  InputsTableViewDataSource.swift
//  Jirassic
//
//  Created by Cristian Baluta on 01/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa
import RCLog

enum InputType {
    case shell
    case jirassic
    case git
    case jit
    case browser
    case calendar
    static var all: [InputType] = [.shell, .jirassic, .git, .jit, .browser, .calendar]
}

class InputsTableViewDataSource: NSObject {

    private let cells: [InputType] = InputType.all
    private let tableView: NSTableView!

    var shellCompatibility: Compatibility? {
        didSet {
            tableView.reloadData(forRowIndexes: IndexSet(integer: 0), columnIndexes: IndexSet(integer: 0))
        }
    }
    var jirassicCompatibility: Compatibility? {
        didSet {
            tableView.reloadData()
        }
    }
    var jitCompatibility: Compatibility? {
        didSet {
            tableView.reloadData()
        }
    }
    var browserCompatibility: Compatibility? {
        didSet {
            tableView.reloadData()
        }
    }
    var browserSettings: SettingsBrowser? {
        didSet {
            tableView.reloadData()
        }
    }
    var gitAvailable: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    var onPurchasePressed: (() -> Void)?

    init (tableView: NSTableView) {
        self.tableView = tableView
        super.init()
    }

    deinit {
        RCLogO("deinit")
    }
}

extension InputsTableViewDataSource: NSTableViewDataSource {
    
    func numberOfRows (in aTableView: NSTableView) -> Int {
        return cells.count
    }
    
    func tableView (_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        let inputType = cells[row]
        switch inputType {
        case .shell:
            return ShellCell.height
        case .jirassic:
            return JirassicCell.height
        case .git:
            return GitCell.height
        case .jit:
            return JitCell.height
        case .browser:
            return BrowserCell.height
        case .calendar:
            return CalendarCell.height
        }
    }
}

extension InputsTableViewDataSource: NSTableViewDelegate {
    
    func tableView (_ tableView: NSTableView,
                    viewFor tableColumn: NSTableColumn?,
                    row: Int) -> NSView? {

        switch cells[row] {
        case .shell:
            let cell = ShellCell.instantiateFromXib()
            if let shellCompatibility {
                cell.setShellStatus(compatibility: shellCompatibility)
            }
            return cell
        case .jirassic:
            let cell = JirassicCell.instantiateFromXib()
            if let jirassicCompatibility {
                cell.setJirassicStatus(compatibility: jirassicCompatibility)
            }
            return cell
        case .git:
            let cell = GitCell.instantiateFromXib()
//            if let gitCompatibility {
//                cell.(compatibility: jitCompatibility)
//            }
            cell.onPurchasePressed = { [weak self] in
                self?.onPurchasePressed?()
            }
            return cell
        case .jit:
            let cell = JitCell.instantiateFromXib()
            if let jitCompatibility {
                cell.setJitStatus(compatibility: jitCompatibility)
            }
            return cell
        case .browser:
            let cell = BrowserCell.instantiateFromXib()
            if let browserCompatibility {
                cell.setBrowserStatus(compatibility: browserCompatibility)
            }
            if let browserSettings {
                cell.showSettings(browserSettings)
            }
            return cell
        case .calendar:
            let cell = CalendarCell.instantiateFromXib()
            return cell
        }
    }
}

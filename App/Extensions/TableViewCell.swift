//
//  TableView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 25/03/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

#if os(iOS)
    import UIKit
    typealias TableViewCell = UITableViewCell
    typealias TableView = UITableView
#else
    import Cocoa
    typealias TableViewCell = NSTableRowView
    typealias TableView = NSTableView
#endif

extension TableViewCell {
    
    class func register (in tableView: TableView) {
        return  register(in: tableView, type: self)
    }
    
    fileprivate class func register<T> (in tableView: TableView, type: T.Type) {
        #if os(iOS)
            return UIStoryboard(name: name, bundle: nil).instantiateViewControllerWithIdentifier(self.className) as! T
        #else
            let className = String(describing: self)
            assert(NSNib(nibNamed: NSNib.Name(rawValue: className), bundle: Bundle.main) != nil, "err")
            
            if let nib = NSNib(nibNamed: NSNib.Name(rawValue: className), bundle: Bundle.main) {
                tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: className))
            }
        #endif
    }
}


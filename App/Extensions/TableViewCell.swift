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
        return register(in: tableView, type: self)
    }
    
    private class func register<T> (in tableView: TableView, type: T.Type) {
        #if os(iOS)
//            return UIStoryboard(name: name, bundle: nil).instantiateViewControllerWithIdentifier(self.className) as! T
        #else
            let className = String(describing: self)
            assert(NSNib(nibNamed: className, bundle: Bundle.main) != nil, "err")
            
            if let nib = NSNib(nibNamed: className, bundle: Bundle.main) {
                tableView.register(nib, forIdentifier: NSUserInterfaceItemIdentifier(rawValue: className))
            }
        #endif
    }
    
    class func instantiate (in tableView: TableView) -> Self {
        return instantiate(in: tableView, type: self)
    }
    
    private class func instantiate<T> (in tableView: TableView, type: T.Type) -> T {
        let className = String(describing: self)
        #if os(iOS)
//            return UIStoryboard(name: name, bundle: nil).instantiateViewControllerWithIdentifier(self.className) as! T
        #else
            guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: className), owner: self) as? T else {
                fatalError("Cell \(className) might not be registered in thsi tableView")
            }
            return cell
        #endif
    }
}

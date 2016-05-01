//
//  UIViewControllerStoryboard.swift
//  Jirassic
//
//  Created by Cristian Baluta on 02/05/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

#if os(iOS)
    import UIKit
    typealias ViewController = UIViewController
#else
    import Cocoa
    typealias ViewController = NSViewController
#endif

extension ViewController {
    
    class func instantiateFromStoryboard (name: String) -> Self {
        return  instantiateFromStoryboard(name, type: self)
    }
    
    private class func instantiateFromStoryboard<T> (name: String, type: T.Type) -> T {
        #if os(iOS)
            return UIStoryboard(name: name, bundle: nil).instantiateViewControllerWithIdentifier(self.className) as! T
        #else
            return NSStoryboard(name: name, bundle: nil).instantiateControllerWithIdentifier(String(self)) as! T
        #endif
    }
}

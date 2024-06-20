//
//  ViewXib.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

#if os(iOS)
import UIKit
typealias AView = UIView
#else
import Cocoa
typealias AView = NSView
#endif

extension AView {
    
    class func instantiateFromXib() -> Self {
        return instantiateFromXib(type: self)
    }
    
    private class func instantiateFromXib<T> (type: T.Type) -> T {
        #if os(iOS)
//        return UIStoryboard(name: name, bundle: nil).instantiateViewControllerWithIdentifier(self.className) as! T
        #else
        let className = String(describing: T.self)
        var views: NSArray?
        Bundle.main.loadNibNamed(className, owner: nil, topLevelObjects: &views)
        for subview in views ?? [] {
            if let s = subview as? T {
                return s
            }
        }
        fatalError("Nib or view \(className) not found")
        #endif
    }
}

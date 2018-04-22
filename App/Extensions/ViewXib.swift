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
        return  instantiateFromXib(type: self)
    }
    
    fileprivate class func instantiateFromXib<T> (type: T.Type) -> T {
        #if os(iOS)
//        return UIStoryboard(name: name, bundle: nil).instantiateViewControllerWithIdentifier(self.className) as! T
        #else
        var view: T?
        var views: NSArray?
        Bundle.main.loadNibNamed(NSNib.Name(rawValue: String(describing: T.self)),
                                 owner: nil,
                                 topLevelObjects: &views)
        if let v = views {
            for _v in v {
                if let __v = _v as? T {
                    view = __v
                }
            }
        }
        return view!
        #endif
    }
}

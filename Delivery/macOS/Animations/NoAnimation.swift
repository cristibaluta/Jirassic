//
//  NoAnimation.swift
//  Jirassic
//
//  Created by Cristian Baluta on 17/11/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa

class NoAnimation: NSObject {

    var animationReachedMiddle: (() -> ())?
    var animationFinished: (() -> ())?
    weak var layer: CALayer?
    
    func startWithLayer (_ layer: CALayer) {
        self.animationReachedMiddle!()
        self.animationFinished!()
    }
}

//
//  Animatable.swift
//  Jirassic
//
//  Created by Cristian Baluta on 11/12/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

protocol Animatable {
    // Animatable views need a CALayer which should be created in this method
    func createLayer()
}

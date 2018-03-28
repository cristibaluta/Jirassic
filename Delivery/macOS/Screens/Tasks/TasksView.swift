//
//  TasksView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/02/2017.
//  Copyright © 2017 Imagin soft. All rights reserved.
//

import Cocoa

class TasksView: NSView {
    
    override func mouseUp (with theEvent: NSEvent) {
        if theEvent.clickCount == 2 {
            AppDelegate.sharedApp().menu.triggerClose()
        }
    }
}

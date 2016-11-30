//
//  TaskSuggestionPopover.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

class TaskSuggestionPopover: NSPopover {
    
    required init?(coder: NSCoder) {
        super.init()
    }
    
    override func awakeFromNib() {
        //		RCLogO(self.contentViewController)
        //		RCLogRect(self.contentViewController?.view.frame)
    }
    
    func canBecomeKeyWindow() -> Bool {
        return true // Allow Search field to become the first responder
    }
}

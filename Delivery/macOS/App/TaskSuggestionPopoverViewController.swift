//
//  TaskSuggestionPopoverViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

class TaskSuggestionPopoverViewController: NSViewController {
    
    var appWireframe: AppWireframe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appWireframe = AppDelegate.sharedApp().appWireframe
        appWireframe?.viewController = self
        
    }
}


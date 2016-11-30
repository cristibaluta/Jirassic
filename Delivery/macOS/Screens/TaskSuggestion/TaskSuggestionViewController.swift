//
//  TaskSuggestionViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 30/11/2016.
//  Copyright © 2016 Imagin soft. All rights reserved.
//

import Cocoa

class TaskSuggestionViewController: NSViewController {
    
    var presenter: TaskSuggestionPresenterInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

extension TaskSuggestionViewController: TaskSuggestionPresenterOutput {
    
}

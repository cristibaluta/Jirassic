//
//  AppWireframe.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

enum SplitViewColumn: Int {
    case dates = 0
    case tasks = 1
}

class AppWireframe {

    var viewController: NSViewController?
    
    fileprivate var currentController: NSViewController?
    fileprivate var _loginViewController: LoginViewController?
    fileprivate var _tasksViewController: TasksViewController?
    fileprivate var _messageViewController: MessageViewController?
    fileprivate var _newTaskViewController: NewTaskViewController?
    fileprivate var _settingsViewController: SettingsViewController?
    
    var loginViewController: LoginViewController {
        
        guard _loginViewController == nil else {
            return _loginViewController!
        }
        
        let loginController = LoginViewController.instantiateFromStoryboard("Login")
        let loginPresenter = LoginPresenter()
        
        loginController.loginPresenter = loginPresenter
        loginController.view.frame = CGRect(origin: CGPoint.zero, size: self.viewController!.view.frame.size)
        loginPresenter.userInterface = loginController
        
        _loginViewController = loginController
        
        return loginController
    }
    
    var tasksViewController: TasksViewController {
        
        guard _tasksViewController == nil else {
            return _tasksViewController!
        }
        
        let tasksController = TasksViewController.instantiateFromStoryboard("Tasks")
        let tasksPresenter = TasksPresenter()
        
        tasksController.appWireframe = self
        tasksController.tasksPresenter = tasksPresenter
        tasksController.view.frame = CGRect(origin: CGPoint.zero, size: self.viewController!.view.frame.size)
        
        tasksPresenter.userInterface = tasksController
        tasksPresenter.appWireframe = self
        
        _tasksViewController = tasksController
        
        return tasksController
    }
    
    var newTaskViewController: NewTaskViewController {
        
        guard _newTaskViewController == nil else {
            return _newTaskViewController!
        }
        
        _newTaskViewController = NewTaskViewController.instantiateFromStoryboard("Tasks")
        
        return _newTaskViewController!
    }
    
    var settingsViewController: SettingsViewController {
        
        guard _settingsViewController == nil else {
            return _settingsViewController!
        }
        
        let settingsController = SettingsViewController.instantiateFromStoryboard("Settings")
        let presenter = SettingsPresenter()
        let interactor = SettingsInteractor()
        
        presenter.userInterface = settingsController
        presenter.interactor = interactor
        interactor.presenter = presenter
        settingsController.view.frame = CGRect(origin: CGPoint.zero, size: self.viewController!.view.frame.size)
        settingsController.presenter = presenter
        settingsController.appWireframe = self
        
        _settingsViewController = settingsController
        
        return settingsController
    }
    
    var messageViewController: MessageViewController {
        
        guard _messageViewController == nil else {
            return _messageViewController!
        }
        
        _messageViewController = MessageViewController.instantiateFromStoryboard("Main")
        
        return _messageViewController!
    }
}

extension AppWireframe {
	
	func showPopover (_ popover: NSPopover, fromIcon icon: NSView) {
		let edge = NSRectEdge.minY
		let rect = icon.frame
		popover.show(relativeTo: rect, of: icon, preferredEdge: edge);
	}
	
	func hidePopover (_ popover: NSPopover) {
		popover.close()
	}
    
    func showTaskSuggestionPopover (_ popover: NSPopover, fromIcon icon: NSView) {
        let edge = NSRectEdge.minY
        let rect = icon.frame
        popover.show(relativeTo: rect, of: icon, preferredEdge: edge);
    }
    
	fileprivate func addController (_ controller: NSViewController) {
        self.viewController?.addChildViewController(controller)
        self.viewController?.view.addSubview(controller.view)
	}
    
    fileprivate func removeController (_ controller: NSViewController) {
        controller.removeFromParentViewController()
        controller.view.removeFromSuperview()
    }
    
    fileprivate func layerToAnimate() -> CALayer {
        return self.viewController!.view.superview!.layer!
    }
}

extension AppWireframe {
    
    func presentLoginController() {
        
        let loginController = self.loginViewController
        addController(loginController)
        
        currentController = loginController
    }
    
    func flipToLoginController() {
        
        let loginController = self.loginViewController
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
            self.removeController(self.currentController!)
            self.addController(loginController)
            self.currentController = loginController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
    }
}

extension AppWireframe {
    
    func presentTasksController() {
        
        let tasksController = self.tasksViewController
        addController(tasksController)
        
        currentController = tasksController
    }
    
    func flipToTasksController() {
        
        let tasksController = self.tasksViewController
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
            self.removeController(self.currentController!)
            self.addController(tasksController)
            self.currentController = tasksController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
    }
}

extension AppWireframe {
    
    func presentMessage (_ message: MessageViewModel, intoSplitView splitView: NSSplitView) {
        
        let messageController = self.messageViewController
        if messageController.parent == nil {
            self.viewController!.addChildViewController(messageController)
            splitView.subviews[SplitViewColumn.tasks.rawValue].addSubview(messageController.view)
            messageController.view.constrainToSuperview()
        }
        messageViewController.viewModel = message
    }
    
    func removeMessage() {
        if let controller = _messageViewController {
            removeController(controller)
            _messageViewController = nil
        }
    }
}

extension AppWireframe {
    
    func presentNewTaskController () {
        
        let taskController = self.newTaskViewController
        addController(taskController)
        taskController.view.constrainToSuperview()
    }
    
    func removeNewTaskController() {
        if let controller = _newTaskViewController {
            removeController(controller)
            _newTaskViewController = nil
        }
    }
}

extension AppWireframe {
    
    func flipToSettingsController() {
        
        let settingsController = self.settingsViewController
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
            self.removeController(self.currentController!)
            self.addController(settingsController)
            self.currentController = settingsController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
    }
}

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

    fileprivate var _appViewController: AppViewController?
    
    fileprivate var currentController: NSViewController?
    fileprivate var _tasksViewController: TasksViewController?
    fileprivate var _messageViewController: MessageViewController?
    fileprivate var _newTaskViewController: NewTaskViewController?
    
    var appViewController: AppViewController {
        
        guard _appViewController == nil else {
            return _appViewController!
        }
        _appViewController = AppViewController.instantiateFromStoryboard("Main")
        
        return _appViewController!
    }
    
    var loginViewController: LoginViewController {
        
        let controller = LoginViewController.instantiateFromStoryboard("Login")
        let presenter = LoginPresenter()
        
        controller.loginPresenter = presenter
        presenter.userInterface = controller
        
        return controller
    }
    
    var tasksViewController: TasksViewController {
        
        guard _tasksViewController == nil else {
            return _tasksViewController!
        }
        
        let controller = TasksViewController.instantiateFromStoryboard("Tasks")
        let presenter = TasksPresenter()
        
        controller.appWireframe = self
        controller.tasksPresenter = presenter
//        controller.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 500, height: 500))
        
        presenter.userInterface = controller
        presenter.appWireframe = self
        
        _tasksViewController = controller
        
        return controller
    }
    
    var taskSuggestionViewController: TaskSuggestionViewController {
        
        let controller = TaskSuggestionViewController.instantiateFromStoryboard("Tasks")
        let presenter = TaskSuggestionPresenter()
        
        controller.presenter = presenter
        presenter.userInterface = controller
        
        return controller
    }
    
    var newTaskViewController: NewTaskViewController {
        
        guard _newTaskViewController == nil else {
            return _newTaskViewController!
        }
        
        _newTaskViewController = NewTaskViewController.instantiateFromStoryboard("Tasks")
        
        return _newTaskViewController!
    }
    
    var settingsViewController: SettingsViewController {
        
        let controller = SettingsViewController.instantiateFromStoryboard("Settings")
        let presenter = SettingsPresenter()
        let interactor = SettingsInteractor()
        
        presenter.userInterface = controller
        presenter.interactor = interactor
        interactor.presenter = presenter
        controller.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 500, height: 500))
        controller.presenter = presenter
        controller.appWireframe = self
        
        return controller
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
    
	fileprivate func addController (_ controller: NSViewController) {
        _appViewController?.addChildViewController(controller)
        _appViewController?.view.addSubview(controller.view)
        controller.view.constrainToSuperview()
	}
    
    fileprivate func removeController (_ controller: NSViewController) {
        controller.removeFromParentViewController()
        controller.view.removeFromSuperview()
    }
    
    fileprivate func layerToAnimate() -> CALayer {
        return _appViewController!.view.superview!.layer!
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
        
        _appViewController?.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 560, height: 500))
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
    
    func presentTaskSuggestionController (startSleepDate: Date?, endSleepDate: Date) {
        
        if let cc = currentController {
            removeController(cc)
            currentController = nil
        }
        _appViewController?.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 450, height: 150))
        let controller = self.taskSuggestionViewController
        addController(controller)
        
//        ComputerWakeUpInteractor(repository: localRepository).runWith(lastSleepDate: startSleepDate)
        
    }
}

extension AppWireframe {
    
    func presentMessage (_ message: MessageViewModel, intoSplitView splitView: NSSplitView) {
        
        let messageController = self.messageViewController
        if messageController.parent == nil {
            _appViewController?.addChildViewController(messageController)
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

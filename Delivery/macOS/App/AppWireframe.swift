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
    fileprivate var _messageViewController: MessageViewController?
    fileprivate var _newTaskViewController: NewTaskViewController?
    
    var appViewController: AppViewController {
        
        guard _appViewController == nil else {
            return _appViewController!
        }
        _appViewController = AppViewController.instantiateFromStoryboard("Main")
        
        return _appViewController!
    }
    
    fileprivate var loginViewController: LoginViewController {
        
        let controller = LoginViewController.instantiateFromStoryboard("Login")
        let presenter = LoginPresenter()
        
        controller.loginPresenter = presenter
        presenter.userInterface = controller
        
        return controller
    }
    
    fileprivate var tasksViewController: TasksViewController {
        
        let controller = TasksViewController.instantiateFromStoryboard("Tasks")
        let presenter = TasksPresenter()
        
        controller.appWireframe = self
        controller.tasksPresenter = presenter
        presenter.userInterface = controller
        presenter.appWireframe = self
        
        return controller
    }
    
    fileprivate var taskSuggestionViewController: TaskSuggestionViewController {
        
        let controller = TaskSuggestionViewController.instantiateFromStoryboard("Tasks")
        let presenter = TaskSuggestionPresenter()
        
        controller.presenter = presenter
        presenter.userInterface = controller
        
        return controller
    }
    
    fileprivate var newTaskViewController: NewTaskViewController {
        return NewTaskViewController.instantiateFromStoryboard("Tasks")
    }
    
    fileprivate var settingsViewController: SettingsViewController {
        
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
    
    fileprivate var messageViewController: MessageViewController {
        return MessageViewController.instantiateFromStoryboard("Main")
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
    
    func removeCurrentController() {
        if let c = currentController {
            removeController(c)
            currentController = nil
        }
    }
    
	fileprivate func addController (_ controller: NSViewController) {
        _appViewController!.addChildViewController(controller)
        _appViewController!.view.addSubview(controller.view)
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
    
    func presentTasksController() {
        
        _appViewController!.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 560, height: 500))
        let controller = self.tasksViewController
        addController(controller)
        
        currentController = controller
    }
    
    func presentTaskSuggestionController (startSleepDate: Date?, endSleepDate: Date) {
        
        _appViewController!.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 450, height: 150))
        let controller = self.taskSuggestionViewController
        controller.startSleepDate = startSleepDate
        controller.endSleepDate = endSleepDate
        addController(controller)
        currentController = controller
    }
    
    func presentMessage (_ message: MessageViewModel, intoSplitView splitView: NSSplitView) -> MessageViewController {
        
        var controller = _messageViewController
        
        if controller == nil {
            controller = self.messageViewController
            _appViewController!.addChildViewController(controller!)
            splitView.subviews[SplitViewColumn.tasks.rawValue].addSubview(controller!.view)
            controller!.view.constrainToSuperview()
            _messageViewController = controller
        }
        controller!.viewModel = message
        
        return controller!
    }
    
    func removeMessage() {
        if let controller = _messageViewController {
            removeController(controller)
            _messageViewController = nil
        }
    }
    
    func presentNewTaskController() -> NewTaskViewController {
        
        let controller = self.newTaskViewController
        addController(controller)
        controller.view.constrainToSuperview()
        _newTaskViewController = controller
        
        return controller
    }
    
    func removeNewTaskController() {
        if let controller = _newTaskViewController {
            removeController(controller)
            _newTaskViewController = nil
        }
    }
}

extension AppWireframe {
    
    func flipToTasksController() {
        
        let tasksController = self.tasksViewController
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
            self.removeCurrentController()
            self.addController(tasksController)
            self.currentController = tasksController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
    }
    
    func flipToSettingsController() {
        
        let settingsController = self.settingsViewController
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
            self.removeCurrentController()
            self.addController(settingsController)
            self.currentController = settingsController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
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

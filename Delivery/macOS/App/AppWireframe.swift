//
//  AppWireframe.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

enum SplitViewColumn: Int {
    case calendar = 0
    case tasks = 1
}

class AppWireframe {

    private var _appViewController: AppViewController?
    private var currentController: NSViewController?
    private var _placeholderViewController: PlaceholderViewController?
    private var _endDayViewController: EndDayViewController?
    
    var appViewController: AppViewController {
        
        guard _appViewController == nil else {
            return _appViewController!
        }
        _appViewController = AppViewController.instantiateFromStoryboard("Main")
        
        return _appViewController!
    }
    
    private var welcomeViewController: WelcomeViewController {
        
        let controller = WelcomeViewController.instantiateFromStoryboard("Welcome")
        controller.appWireframe = self
        
        return controller
    }
    
    private var wizardViewController: WizardViewController {
        
        let controller = WizardViewController.instantiateFromStoryboard("Welcome")
        controller.appWireframe = self
        
        return controller
    }
    
    private var loginViewController: LoginViewController {
        
        let controller = LoginViewController.instantiateFromStoryboard("Login")
        let presenter = LoginPresenter()
        
        controller.loginPresenter = presenter
        presenter.userInterface = controller
        
        return controller
    }
    
    private var tasksViewController: TasksViewController {
        
        let controller = TasksViewController.instantiateFromStoryboard("Tasks")
        let presenter = TasksPresenter()
        let interactor = TasksInteractor()
        
        presenter.ui = controller
        presenter.interactor = interactor
        presenter.appWireframe = self
        interactor.presenter = presenter
        controller.presenter = presenter
        controller.appWireframe = self
        
        return controller
    }
    
    private var taskSuggestionViewController: TaskSuggestionViewController {
        
        let controller = TaskSuggestionViewController.instantiateFromStoryboard("Tasks")
        let presenter = TaskSuggestionPresenter()
        
        controller.presenter = presenter
        presenter.userInterface = controller
        
        return controller
    }
    
    private var settingsViewController: SettingsViewController {
        
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
    
    private var placeholderViewController: PlaceholderViewController {
        return PlaceholderViewController.instantiateFromStoryboard("Placeholder")
    }

    private var endDayViewController: EndDayViewController {

        let controller = EndDayViewController.instantiateFromStoryboard("EndDay")
        let presenter = EndDayPresenter()

        controller.presenter = presenter
        controller.appWireframe = self
        presenter.userInterface = controller

        return controller
    }

}

extension AppWireframe {
	
	func showPopover (_ popover: NSPopover, fromIcon icon: NSView) {
		let edge = NSRectEdge.minY
		let rect = icon.frame
		popover.show(relativeTo: rect, of: icon, preferredEdge: edge)
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
    
	private func addController (_ controller: NSViewController) {
        appViewController.addChildViewController(controller)
        appViewController.view.addSubview(controller.view)
        controller.view.constrainToSuperview()
	}
    
    private func removeController (_ controller: NSViewController) {
        controller.removeFromParentViewController()
        controller.view.removeFromSuperview()
    }
    
    private func layerToAnimate() -> CALayer {
        return appViewController.view.superview!.layer!
    }
}

extension AppWireframe {
    
    func presentWelcomeController() -> WelcomeViewController {
        
        appViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 560, height: 500))
        let controller = self.welcomeViewController
        addController(controller)
        currentController = controller
        
        return controller
    }
    
    func presentWizardController() -> WizardViewController {
        
        appViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 560, height: 500))
        let controller = self.wizardViewController
        addController(controller)
        currentController = controller
        
        return controller
    }
    
    func presentLoginController() -> LoginViewController {
        
        let controller = self.loginViewController
        addController(controller)
        currentController = controller
        
        return controller
    }
    
    func presentTasksController() -> TasksViewController {
        
        appViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 560, height: 500))
        let controller = self.tasksViewController
        addController(controller)
        currentController = controller
        
        return controller
    }
    
    func presentTaskSuggestionController (startSleepDate: Date?, endSleepDate: Date) -> TaskSuggestionViewController {
        
        appViewController.view.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: 450, height: 150))
        let controller = self.taskSuggestionViewController
        controller.startSleepDate = startSleepDate
        controller.endSleepDate = endSleepDate
        addController(controller)
        currentController = controller
        
        return controller
    }

    // Placeholder
    func presentPlaceholder (_ message: MessageViewModel, intoSplitView splitView: NSSplitView) -> PlaceholderViewController {
        
        var controller = _placeholderViewController
        
        if controller == nil {
            controller = self.placeholderViewController
            appViewController.addChildViewController(controller!)
            _placeholderViewController = controller
        }
        splitView.subviews[SplitViewColumn.tasks.rawValue].addSubview(controller!.view)
        controller!.view.constrainToSuperview()
        controller!.viewModel = message
        
        return controller!
    }
    
    func removePlaceholder() {
        if let controller = _placeholderViewController {
            removeController(controller)
            _placeholderViewController = nil
        }
    }

    // EndDay
    func presentEndDayController (date: Date, tasks: [Task]) -> EndDayViewController {

        let controller = self.endDayViewController
        controller.date = date
        controller.tasks = tasks
        addController(controller)
        controller.view.constrainToSuperview()
        _endDayViewController = controller

        return controller
    }

    func removeEndDayController() {
        if let controller = _endDayViewController {
            removeController(controller)
            _endDayViewController = nil
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
            self.removePlaceholder()
            self.removeEndDayController()
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
    
    func flipToWizardController() {
        
        let wizardController = self.wizardViewController
        let flip = FlipAnimation()
        flip.animationReachedMiddle = {
            self.removeCurrentController()
            self.removePlaceholder()
            self.removeEndDayController()
            self.addController(wizardController)
            self.currentController = wizardController
        }
        flip.animationFinished = {}
        flip.startWithLayer(layerToAnimate())
    }
}

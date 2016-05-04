//
//  AppWireframe.swift
//  Jirassic
//
//  Created by Baluta Cristian on 06/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class AppWireframe {

	// MARK: Popover
	
	func showPopover (popover: NSPopover, fromIcon icon: NSView) {
		let edge = NSRectEdge.MinY
		let rect = icon.frame
		popover.showRelativeToRect(rect, ofView: icon, preferredEdge: edge);
	}
	
	func hidePopover (popover: NSPopover) {
		popover.close()
	}
	
	// MARK: Settings
	
	func flipToSettings (settingsController: NSViewController,
		parentController: NSViewController,
		currentController: NSViewController,
		completion: (controller: NSViewController) -> Void) {
		
		let flip = FlipScreens()
		flip.animationReachedMiddle = {
			// Remove current controller
			currentController.view.removeFromSuperview()
			currentController.removeFromParentViewController()
			// Add new controller
			parentController.addChildViewController(settingsController)
			parentController.view.addSubview(settingsController.view)
		}
		flip.animationFinished = {
			completion(controller: settingsController)
		}
		flip.startWithLayer(parentController.view.superview!.layer!)
	}
	
	func flipToLogin() {
		
//		let flip = FlipScreens()
//		flip.animationReachedMiddle = {
//			self.removeTasksController()
//			self.view.addSubview( self.createLoginController().view )
//		}
//		flip.animationFinished = {
//			
//		}
//		flip.startWithLayer(self.view.superview!.layer!)
	}
	
	func flipToTasks (tasksController: NSViewController,
		parentController: NSViewController,
		currentController: NSViewController,
		completion: (controller: NSViewController) -> Void) {
		
		let flip = FlipScreens()
		flip.animationReachedMiddle = {
			// Remove current controller
			currentController.view.removeFromSuperview()
			currentController.removeFromParentViewController()
			// Add new controller
			parentController.addChildViewController(tasksController)
			parentController.view.addSubview(tasksController.view)
		}
		flip.animationFinished = {
			completion(controller: tasksController)
		}
		flip.startWithLayer(parentController.view.superview!.layer!)
	}
	
	func presentNoTaskController (controller: NSViewController,
		overController parentController: NSViewController,
		splitView: NSSplitView) {
		
		parentController.addChildViewController(controller)
		splitView.subviews[1].addSubview(controller.view)
		controller.view.constrainToSuperview()
	}
	
	func removeController (controller: NSViewController) {
		controller.removeFromParentViewController()
		controller.view.removeFromSuperview()
	}
	
	func presentNewTaskController (controller: NSViewController,
		overController parentController: NSViewController,
		splitView: NSSplitView) {
		
		parentController.addChildViewController(controller)
        parentController.view.addSubview(controller.view)
        controller.view.constrainToSuperviewWidth()
        controller.view.constrainToSuperviewHeight(70, bottom: 0)
	}
	
	func removeNoProjectsController (controller: NSViewController?) {
		
		if let c = controller {
			c.view.removeFromSuperview()
			c.removeFromParentViewController()
		}
	}
}

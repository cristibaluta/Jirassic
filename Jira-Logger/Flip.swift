//
//  Flip.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 24/05/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class Flip: NSObject {

	var animationReachedMiddle: (() -> ())?
	var animationFinished: (() -> ())?
	
	func startWithLayer(layer: CALayer) {
		
		// Create CAAnimation
		let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.y")
		rotationAnimation.fromValue = 0.0
		rotationAnimation.toValue = 3.14/2
		rotationAnimation.duration = 0.4
		rotationAnimation.repeatCount = 1.0
		rotationAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		rotationAnimation.fillMode = kCAFillModeForwards
		rotationAnimation.removedOnCompletion = false
		rotationAnimation.setValue("flipAnimationInwards", forKey: "flip")
		rotationAnimation.delegate = self
		
		// Add perspective
		var mt = CATransform3DIdentity
		mt.m34 = CGFloat(1.0 / 1000)
		layer.transform = mt
		
		// Set z position so the layer will be on top
		//		lr?.zPosition = 999;
		
		// Keep cards tilted when flipping
		//		if(self.tiltCard)
		//		self.frameCenterRotation = self.frameCenterRotation;
		
		// Do rotation
		layer.addAnimation(rotationAnimation, forKey:"flip")
	}
}

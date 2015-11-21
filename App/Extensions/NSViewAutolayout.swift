//
//  NSViewAutolayout.swift
//  Spoto
//
//  Created by Baluta Cristian on 15/07/15.
//  Copyright (c) 2015 Baluta Cristian. All rights reserved.
//

import Cocoa

extension NSView {
	
	func removeAutoresizing() {
		self.translatesAutoresizingMaskIntoConstraints = false
	}
	
	func constrainToSuperview() {
		self.removeAutoresizing()
		self.constrainToSuperviewWidth()
		self.constrainToSuperviewHeight()
	}
	
	func constrainToSuperviewWidth() {
		self.removeAutoresizing()
		let viewsDictionary = ["view": self]
		self.superview!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
			"H:|-0-[view]-0-|", options: [], metrics: nil, views: viewsDictionary))
	}
	
	func constrainToSuperviewHeight(top: CGFloat=0.0, bottom: CGFloat=0.0) {
		self.removeAutoresizing()
		let viewsDictionary = ["view": self]
		let metricsDictionary = ["top": top, "bottom": bottom]
		self.superview!.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
			"V:|-top-[view]-bottom-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
	}
	
	func constrainHorizontally(leftView: NSView, rightView: NSView, distance: CGFloat) {
		let viewsDictionary = ["leftView": leftView, "rightView": rightView]
		let metricsDictionary = ["distance": distance]
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
			"H:[leftView]-distance-[rightView]", options: [], metrics: metricsDictionary, views: viewsDictionary))
	}
	
	func constraintVertically(topView: NSView, bottomView: NSView, distance: CGFloat) {
		let viewsDictionary = ["topView": topView, "bottomView": bottomView]
		let metrics = ["gap": distance]
		self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
			"V:[topView]-gap-[bottomView]", options: [], metrics: metrics, views: viewsDictionary))
	}
	
	func constraintToTop(view: NSView, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal,
			toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToBottom(view: NSView, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal,
			toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToLeft(view: NSView, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal,
			toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToRight(view: NSView, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal,
			toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constrainToWidth(width: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal,
			toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: width)
		self.superview!.addConstraint(constraint)
		return constraint
	}
	
	func constrainToHeight(height: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal,
			toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: height)
		self.superview!.addConstraint(constraint)
		return constraint
	}
	
	func centerY(offset: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal,
			toItem: self.superview!, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: offset)
		self.superview!.addConstraint(constraint)
		return constraint
	}
}

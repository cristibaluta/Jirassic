//
//  NSViewAutolayout.swift
//  Spoto
//
//  Created by Baluta Cristian on 15/07/15.
//  Copyright (c) 2015 Baluta Cristian. All rights reserved.
//

#if os(iOS)
    import UIKit
    typealias View = UIView
#else
    import Cocoa
    typealias View = NSView
#endif

extension View {
    
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
		self.superview!.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:|-0-[view]-0-|", options: [], metrics: nil, views: viewsDictionary))
	}
	
	func constrainToSuperviewHeight (_ top: CGFloat=0.0, bottom: CGFloat=0.0) {
		self.removeAutoresizing()
		let viewsDictionary = ["view": self]
        let metricsDictionary: [String : NSNumber] = ["top": NSNumber(value: Float(top)), "bottom": NSNumber(value: Float(bottom))]
		self.superview!.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:|-top-[view]-bottom-|", options: [], metrics: metricsDictionary, views: viewsDictionary))
	}
	
	func constrainHorizontally (_ leftView: View, rightView: View, distance: CGFloat) {
		let viewsDictionary = ["leftView": leftView, "rightView": rightView]
		let metricsDictionary: [String : NSNumber] = ["distance": NSNumber(value: Float(distance))]
		self.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "H:[leftView]-distance-[rightView]", options: [], metrics: metricsDictionary, views: viewsDictionary))
	}
	
	func constraintVertically (_ topView: View, bottomView: View, distance: CGFloat) {
		let viewsDictionary = ["topView": topView, "bottomView": bottomView]
		let metrics: [String : NSNumber] = ["gap": NSNumber(value: Float(distance))]
		self.addConstraints(NSLayoutConstraint.constraints(
			withVisualFormat: "V:[topView]-gap-[bottomView]", options: [], metrics: metrics, views: viewsDictionary))
	}
	
	func constraintToTop (_ view: View, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal,
			toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToBottom (_ view: View, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal,
			toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToLeft (_ view: View, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal,
			toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToRight (_ view: View, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal,
			toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constrainToWidth (_ width: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal,
			toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: width)
		self.superview!.addConstraint(constraint)
		return constraint
	}
	
	func constrainToHeight (_ height: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal,
			toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: height)
		self.superview!.addConstraint(constraint)
		return constraint
	}
	
	func centerY (_ offset: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal,
			toItem: self.superview!, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: offset)
		self.superview!.addConstraint(constraint)
		return constraint
	}
}

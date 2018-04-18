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
			attribute: topAttribute(), relatedBy: equalRelation(),
			toItem: self, attribute: topAttribute(), multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToBottom (_ view: View, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: bottomAttribute(), relatedBy: equalRelation(),
			toItem: self, attribute: bottomAttribute(), multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToLeft (_ view: View, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: leftAttribute(), relatedBy: equalRelation(),
			toItem: self, attribute: leftAttribute(), multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constraintToRight (_ view: View, distance: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: view,
			attribute: rightAttribute(), relatedBy: equalRelation(),
			toItem: self, attribute: rightAttribute(), multiplier: 1, constant: distance)
		self.addConstraint(constraint)
		return constraint
	}
	
	func constrainToWidth (_ width: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: widthAttribute(), relatedBy: equalRelation(),
			toItem: nil, attribute: noAttribute(), multiplier: 1, constant: width)
		self.superview!.addConstraint(constraint)
		return constraint
	}
	
	func constrainToHeight (_ height: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: heightAttribute(), relatedBy: equalRelation(),
			toItem: nil, attribute: noAttribute(), multiplier: 1, constant: height)
		self.superview!.addConstraint(constraint)
		return constraint
	}

    func centerX (_ offset: CGFloat) -> NSLayoutConstraint {
        let constraint = NSLayoutConstraint(item: self,
                                            attribute: centerXAttribute(), relatedBy: equalRelation(),
                                            toItem: self.superview!, attribute: centerXAttribute(), multiplier: 1, constant: offset)
        self.superview!.addConstraint(constraint)
        return constraint
    }

	func centerY (_ offset: CGFloat) -> NSLayoutConstraint {
		let constraint = NSLayoutConstraint(item: self,
			attribute: centerYAttribute(), relatedBy: equalRelation(),
			toItem: self.superview!, attribute: centerYAttribute(), multiplier: 1, constant: offset)
		self.superview!.addConstraint(constraint)
		return constraint
	}

    #if os(iOS)
    func leftAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.left }
    func rightAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.right }
    func topAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.top }
    func bottomAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.bottom }
    func widthAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.width }
    func heightAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.height }
    func centerXAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.centerX }
    func centerYAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.centerY }
    func noAttribute() -> NSLayoutAttribute { return NSLayoutAttribute.notAnAttribute }
    func equalRelation() -> NSLayoutRelation { return NSLayoutRelation.equal }
    #else
    func leftAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.left }
    func rightAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.right }
    func topAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.top }
    func bottomAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.bottom }
    func widthAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.width }
    func heightAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.height }
    func centerXAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.centerX }
    func centerYAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.centerY }
    func noAttribute() -> NSLayoutConstraint.Attribute { return NSLayoutConstraint.Attribute.notAnAttribute }
    func equalRelation() -> NSLayoutConstraint.Relation { return NSLayoutConstraint.Relation.equal }
    #endif
}

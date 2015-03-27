//
//  PanelBackgroundView.swift
//  Jira Logger
//
//  Created by Baluta Cristian on 25/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

let FILL_OPACITY = CGFloat(0.9)
let STROKE_OPACITY = CGFloat(1.0)
let LINE_THICKNESS = CGFloat(1.0)
let CORNER_RADIUS = CGFloat(10.0)
let SEARCH_INSET = 10.0
let ARROW_HEIGHT = CGFloat(8)
let ARROW_WIDTH = CGFloat(12)

class PanelBackgroundView: NSView {

	var _arrowX :NSInteger?
	
    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
		
		let contentRect = NSInsetRect(self.bounds, LINE_THICKNESS, LINE_THICKNESS)
		var path = NSBezierPath()
		
		path.moveToPoint( NSPoint(x: CGFloat(_arrowX!), y: NSMaxY(contentRect)))
		
		path.lineToPoint( NSPoint(x: CGFloat(_arrowX!) + ARROW_WIDTH / 2, y: NSMaxY(contentRect) - ARROW_HEIGHT))
		path.lineToPoint( NSPoint(x: NSMaxX(contentRect) - CORNER_RADIUS, y: NSMaxY(contentRect) - ARROW_HEIGHT))
		
		let topRightCorner = NSPoint(x: NSMaxX(contentRect), y: NSMaxY(contentRect) - ARROW_HEIGHT);
		path.curveToPoint( NSPoint(x: NSMaxX(contentRect), y: NSMaxY(contentRect) - ARROW_HEIGHT - CORNER_RADIUS),
			controlPoint1: topRightCorner,
			controlPoint2: topRightCorner)
		
		path.lineToPoint( NSPoint(x: NSMaxX(contentRect), y: NSMinY(contentRect) + CORNER_RADIUS))
		
		let bottomRightCorner = NSPoint(x: NSMaxX(contentRect), y: NSMinY(contentRect))
		path.curveToPoint( NSPoint(x: NSMaxX(contentRect) - CORNER_RADIUS, y: NSMinY(contentRect)),
			controlPoint1: bottomRightCorner,
			controlPoint2: bottomRightCorner)
		
		path.lineToPoint( NSPoint(x: NSMinX(contentRect) + CORNER_RADIUS, y: NSMinY(contentRect)))
		
		path.curveToPoint( NSPoint(x: NSMinX(contentRect), y: NSMinY(contentRect) + CORNER_RADIUS),
			controlPoint1: contentRect.origin,
			controlPoint2: contentRect.origin)
		
		path.lineToPoint( NSPoint(x: NSMinX(contentRect), y: NSMaxY(contentRect) - ARROW_HEIGHT - CORNER_RADIUS))
		
		let topLeftCorner = NSPoint(x: NSMinX(contentRect), y: NSMaxY(contentRect) - ARROW_HEIGHT)
		path.curveToPoint( NSPoint(x: NSMinX(contentRect) + CORNER_RADIUS, y: NSMaxY(contentRect) - ARROW_HEIGHT),
			controlPoint1: topLeftCorner,
			controlPoint2:topLeftCorner)
		
		path.lineToPoint( NSPoint(x: CGFloat(_arrowX!) - ARROW_WIDTH / 2, y: NSMaxY(contentRect) - ARROW_HEIGHT))
		path.closePath()
		
		NSColor(deviceWhite: CGFloat(1.0), alpha: FILL_OPACITY).setFill()
		path.fill()
		
		NSGraphicsContext.saveGraphicsState()
		
		let clip = NSBezierPath(rect: self.bounds)
		clip.appendBezierPath(path)
		clip.addClip()
		
		path.lineWidth = LINE_THICKNESS * 2
		NSColor.whiteColor().setStroke()
		path.stroke()
		
		NSGraphicsContext.restoreGraphicsState()
    }
	
	func setArrowX(value:NSInteger) {
		_arrowX = value
		setNeedsDisplayInRect(self.frame)
	}
}

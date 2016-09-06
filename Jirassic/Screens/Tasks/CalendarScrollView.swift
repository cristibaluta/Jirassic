//
//  DatesScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 30/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class CalendarScrollView: NSScrollView {
	
	@IBOutlet private var outlineView: NSOutlineView?
	var weeks = [Week]()
	var didSelectDay: ((day: Day) -> ())?
    var selectedDay: Day?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		outlineView?.setDataSource(self)
		outlineView?.setDelegate(self)
	}
	
	func reloadData() {
		self.outlineView?.reloadData()
		self.outlineView?.expandItem(nil, expandChildren: true)
	}
    
    func selectDay (dayToSelect: Day) {
        
        var i = -1
        for week in weeks {
            i += 1
            for day in week.days {
                i += 1
                if day.date.isSameDayAs(dayToSelect.date) {
                    let indexSet = NSIndexSet(index: i)
                    outlineView?.selectRowIndexes(indexSet, byExtendingSelection: true)
                    break
                }
            }
        }
    }
}

extension CalendarScrollView: NSOutlineViewDataSource {
	
	func outlineView (outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
		
		if let item: AnyObject = item {
			switch item {
			case let week as Week:
				return week.days[index]
			default:
				return self
			}
		} else {
			return weeks[index]
		}
	}
	
	func outlineView (outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
		
		switch item {
		case let week as Week:
			return week.days.count > 0
		default:
			return false
		}
	}
	
	func outlineView (outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
		
		if let item: AnyObject = item {
			switch item {
			case let week as Week:
				return week.days.count
			default:
				return 0
			}
		} else {
			return weeks.count
		}
	}
}

extension CalendarScrollView: NSOutlineViewDelegate {
	
	func outlineView (outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        
		switch item {
		case let week as Week:
			let view = outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView
			if let textField = view.textField {
				textField.stringValue = week.date.weekInterval()
			}
			return view
		case let day as Day:
			let view = outlineView.makeViewWithIdentifier("DataCell", owner: self) as! NSTableCellView
			if let textField = view.textField {
				textField.stringValue = day.date.ddEEEEE()
			}
			view.imageView!.image = NSImage(named: NSImageNameStatusAvailable)
			return view
		default:
			return nil
		}
	}
	
	func outlineView (outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
		return item is Week
	}
	
	func outlineViewSelectionDidChange (notification: NSNotification) {
		
		let selectedIndex = notification.object?.selectedRow
		let object: AnyObject? = notification.object?.itemAtRow(selectedIndex!)
		
		if let day = (object as? Day) {
            selectedDay = day
			didSelectDay?(day: day)
		}
	}
}

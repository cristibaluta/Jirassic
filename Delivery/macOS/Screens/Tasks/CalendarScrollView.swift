//
//  DatesScrollView.swift
//  Jirassic
//
//  Created by Baluta Cristian on 30/12/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class CalendarScrollView: NSScrollView {
	
	@IBOutlet fileprivate var outlineView: NSOutlineView?
	var weeks = [Week]()
	var didSelectDay: ((_ day: Day) -> ())?
    var selectedDay: Day?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		outlineView?.dataSource = self
		outlineView?.delegate = self
	}
	
	func reloadData() {
		self.outlineView?.reloadData()
		self.outlineView?.expandItem(nil, expandChildren: true)
	}
    
    func selectDay (_ dayToSelect: Day) {
        
        var i = -1
        for week in weeks {
            i += 1
            for day in week.days {
                i += 1
                if day.date.isSameDayAs(dayToSelect.date) {
                    let indexSet = IndexSet(integer: i)
                    outlineView?.selectRowIndexes(indexSet, byExtendingSelection: true)
                    break
                }
            }
        }
    }
}

extension CalendarScrollView: NSOutlineViewDataSource {
	
	func outlineView (_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
		
		if let item: AnyObject = item as AnyObject? {
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
	
	func outlineView (_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
		
		switch item {
		case let week as Week:
			return week.days.count > 0
		default:
			return false
		}
	}
	
	func outlineView (_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
		
		if let item: AnyObject = item as AnyObject? {
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
	
	func outlineView (_ outlineView: NSOutlineView, viewFor viewForTableColumn: NSTableColumn?, item: Any) -> NSView? {
        
		switch item {
		case let week as Week:
			let view = outlineView.make(withIdentifier: "HeaderCell", owner: self) as! NSTableCellView
			if let textField = view.textField {
				textField.stringValue = week.date.weekInterval()
			}
			return view
		case let day as Day:
			let view = outlineView.make(withIdentifier: "DataCell", owner: self) as! NSTableCellView
			if let textField = view.textField {
				textField.stringValue = day.date.ddEEEEE()
			}
            let isToday = day.date.isSameDayAs(Date())
            view.imageView!.image = NSImage(named: isToday ? NSImageNameStatusPartiallyAvailable : NSImageNameStatusAvailable)
			return view
		default:
			return nil
		}
	}
	
	func outlineView (_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
		return item is Week
	}
	
	func outlineViewSelectionDidChange (_ notification: Notification) {
		
        if let outlineView = notification.object as? NSOutlineView {
            let selectedRow = outlineView.selectedRow
            if let selectedObject = outlineView.item(atRow: selectedRow) as? Day {
                selectedDay = selectedObject
                didSelectDay?(selectedObject)
            }
        }
	}
}

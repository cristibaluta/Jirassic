//
//  JLPopoverViewController.swift
//  Jira-Logger
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

enum DrawerState: Int {
	case Closed = 0
	case Open = 1
}

class JLPopoverViewController: NSViewController {
	
	@IBOutlet private var _datesScrollView: NSScrollView?
	@IBOutlet private var _tasksScrollView: NSScrollView?
	@IBOutlet private var _datesTableView: NSTableView?
	@IBOutlet private var _tasksTableView: NSTableView?
	@IBOutlet private var _noTasksLabel: NSTextField?
	@IBOutlet private var _dateLabel: NSTextField?
	@IBOutlet private var _butDrawer: NSButton?
	private var _dateCellDatasource: DateCellDataSource?
	private var _taskCellDatasource: TaskCellDataSource?
	private var _state: DrawerState = .Open
	private let _gapX = CGFloat(12)
	private let kDrawerStateKey = "DrawerStateKey"
	
    override func viewDidLoad() {
		RCLogO("viewDidLoad")
        super.viewDidLoad()
		
		sharedData.allData { (tasks, error) -> Void in
			RCLogO(tasks)
			// Setup delegates for all tableViews
			self.setupDatesTableView()
			self.setupTasksTableView()
			
			self.reloadDataForTasksOnDate( NSDate())
		}
    }
	
	override func viewDidAppear() {
		RCLogO("viewDidAppear")
		super.viewDidAppear()
		
		let previousState = NSUserDefaults.standardUserDefaults().integerForKey(kDrawerStateKey)
		if previousState != self._state.rawValue {
			self._state = .Open
		}
		setState( self._state)
	}
	
	func setupDatesTableView() {
		
		_dateCellDatasource = DateCellDataSource()
		_dateCellDatasource!.tableView = _datesTableView
		_dateCellDatasource!.data = sharedData.days()
		_dateCellDatasource?.didSelectRow = { (row: Int) in
			if row >= 0 {
				let theData = self._dateCellDatasource!.data![row]
				RCLogO(theData)
				self.reloadDataForTasksOnDate( theData.date_task_finished!)
			}
		}
		
//		_datesTableView?.selectionHighlightStyle = NSTableViewSelectionHighlightStyle.None
		_datesTableView?.setDataSource( _dateCellDatasource )
		_datesTableView?.setDelegate( _dateCellDatasource )
	}
	
	func setupTasksTableView() {
		
		_taskCellDatasource = TaskCellDataSource()
		_taskCellDatasource!.tableView = _tasksTableView
		
		_tasksTableView?.setDataSource( _taskCellDatasource )
		_tasksTableView?.setDelegate( _taskCellDatasource )
	}
	
	func reloadDataForTasksOnDate(date: NSDate) {
		
		_noTasksLabel?.hidden = true
		
		_taskCellDatasource!.data = sharedData.tasksForDayOnDate(date)
		_tasksTableView?.reloadData()
		
		_dateLabel?.stringValue = date.EEEEMMdd()
	}
	
	func setState (s: DrawerState) {
		
		_state = s
		
		switch s {
		case .Closed:
			_butDrawer?.image = NSImage(named: NSImageNameGoLeftTemplate)
			_datesScrollView?.hidden = false
			_tasksScrollView?.frame = NSRect(x: CGRectGetWidth(_datesScrollView!.frame) + _gapX,
				y: CGRectGetMinY(_tasksScrollView!.frame),
				width: self.view.frame.size.width - CGRectGetWidth(_datesScrollView!.frame) - _gapX,
				height: CGRectGetHeight(_datesScrollView!.frame))
		case .Open:
			_butDrawer?.image = NSImage(named: NSImageNameGoRightTemplate)
			_datesScrollView?.hidden = true
			_tasksScrollView?.frame = NSRect(x: _gapX,
				y: CGRectGetMinY(_datesScrollView!.frame),
				width: self.view.frame.size.width - _gapX,
				height: CGRectGetHeight(_datesScrollView!.frame))
		default:
			_datesScrollView?.hidden = true
		}
	}
	
	
	// MARK: Actions
	
	@IBAction func handleColumnButton(sender: NSButton) {
		
		setState( _state == .Closed ? .Open : .Closed)
		
		NSUserDefaults.standardUserDefaults().setInteger(_state.rawValue, forKey: kDrawerStateKey)
		NSUserDefaults.standardUserDefaults().synchronize()
		RCLogO(_state.rawValue)
	}
	
	@IBAction func handlePlusButton(sender: NSButton) {
		_taskCellDatasource?.addObjectWithDate( NSDate())
		_tasksTableView?.reloadData()
		_tasksTableView?.scrollColumnToVisible( 0 )
	}
	
	@IBAction func handleShareButton(sender: NSButton) {
		
	}
	
	@IBAction func handleSettingsButton(sender: NSButton) {
		
	}
}

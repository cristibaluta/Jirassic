//
//  TasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksViewController: NSViewController {
	
	@IBOutlet private var splitView: NSSplitView?
	@IBOutlet private var datesScrollView: DatesScrollView?
	@IBOutlet private var tasksScrollView: TasksScrollView?
	@IBOutlet private var _dateLabel: NSTextField?
	@IBOutlet private var _butRefresh: NSButton?
	@IBOutlet private var _progressIndicator: NSProgressIndicator?
	@IBOutlet private var butShare: NSButton?
    
    var appWireframe: AppWireframe?
    var tasksPresenter: TasksPresenterInput?
	
	override func awakeFromNib() {
		view.layer = CALayer()
		view.wantsLayer = true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		registerForNotifications()
        
        datesScrollView?.didSelectDay = { [weak self] (day: Day) in
            self?.tasksPresenter?.reloadTasksOnDay(day.date)
        }
        
        tasksScrollView?.didRemoveRow = { [weak self] (row: Int) in
            RCLogO("Remove item at row \(row)")
            if row >= 0 {
                self?.tasksPresenter?.removeTaskAtRow(row)
                self?.tasksScrollView?.removeTaskAtRow(row)
            }
        }
        tasksScrollView?.didAddRow = { [weak self] (row: Int) -> Void in
            RCLogO("Add item after row \(row)")
            if row >= 0 {
                self?.tasksPresenter?.insertTaskAfterRow(row)
            }
        }
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
        tasksPresenter?.refreshUI()
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	// MARK: Actions
	
	@IBAction func handleSettingsButton (sender: NSButton) {
		appWireframe?.flipToSettingsController()
	}
	
	@IBAction func handleRefreshButton (sender: NSButton) {
		tasksPresenter?.reloadDataFromServer()
	}
	
	@IBAction func handleShareButton (sender: NSButton) {
		tasksPresenter?.createReport()
	}
}

extension TasksViewController: TasksPresenterOutput {
    
    func showLoadingIndicator (show: Bool) {
        if show {
            _progressIndicator?.startAnimation(nil)
        } else {
            _progressIndicator?.stopAnimation(nil)
        }
        self._butRefresh?.hidden = show
    }
    
    func showMessage (message: MessageViewModel) {
        
        appWireframe?.presentMessage(message, intoSplitView: splitView!)
        appWireframe?.messageViewController.didPressButton = tasksPresenter?.messageButtonDidPress
    }
    
    func showDates (weeks: [Week]) {
        
        datesScrollView?.weeks = weeks
        datesScrollView?.reloadData()
    }
    
    func showTasks (tasks: [Task]) {
        
        tasksScrollView?.data = tasks
        tasksScrollView?.reloadData()
        tasksScrollView?.hidden = false
    }
    
    func setSelectedDay (date: String) {
        _dateLabel?.stringValue = date
    }
    
    func presentNewTaskController() {
        
        splitView?.hidden = true
        appWireframe?.removeMessage()
        
        appWireframe?.presentNewTaskController()
        appWireframe?.newTaskViewController.date = NSDate()
        appWireframe?.newTaskViewController.onOptionChosen = { [weak self] (taskData: TaskCreationData) -> Void in
            self?.tasksPresenter?.insertTaskWithData(taskData)
            self?.tasksPresenter?.updateNoTasksState()
            self?.tasksPresenter?.reloadData()
            self?.appWireframe?.removeNewTaskController()
            self?.splitView?.hidden = false
        }
        appWireframe?.newTaskViewController.onCancelChosen = { [weak self] in
            self?.appWireframe?.removeNewTaskController()
            self?.splitView?.hidden = false
            self?.tasksPresenter?.updateNoTasksState()
        }
    }
}

extension TasksViewController {
	
	func registerForNotifications() {
		
		NSNotificationCenter.defaultCenter().addObserver(self,
			selector: #selector(TasksViewController.newTaskWasAdded(_:)),
			name: kNewTaskWasAddedNotification,
			object: nil)
	}
	
	func newTaskWasAdded (notif: NSNotification) {
		
        tasksPresenter?.reloadData()
//		if let task = notif.object as? Task {
//			self.tasksScrollView?.addTask( task )
//			self.tasksScrollView?.tableView?.insertRowsAtIndexes(NSIndexSet(index: 0),
//				withAnimation: NSTableViewAnimationOptions.SlideUp)
//			self.tasksScrollView?.tableView?.scrollRowToVisible( 0 )
//			tasksPresenter?.updateNoTasksState()
//		}
	}
}

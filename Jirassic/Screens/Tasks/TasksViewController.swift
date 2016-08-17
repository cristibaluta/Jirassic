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
    @IBOutlet private var listSegmentedControl: NSSegmentedControl?
    
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
            self?.tasksPresenter?.reloadTasksOnDay(day.date, listType: ListType(rawValue: (self?.listSegmentedControl!.selectedSegment)!)!)
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
	
	@IBAction func handleSegmentedControl (sender: NSSegmentedControl) {
        RCLog(sender.selectedSegment)
        tasksPresenter?.reloadTasksOnDay(NSDate(), listType: ListType(rawValue: sender.selectedSegment)!)
	}
    
    @IBAction func handleQuitAppButton (sender: NSButton) {
        NSApplication.sharedApplication().terminate(nil)
    }
}

extension TasksViewController: TasksPresenterOutput {
    
    func showLoadingIndicator (show: Bool) {
        
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
	}
}

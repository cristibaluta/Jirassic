//
//  TasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksViewController: NSViewController {
	
	@IBOutlet fileprivate var splitView: NSSplitView?
	@IBOutlet fileprivate var calendarScrollView: CalendarScrollView?
	@IBOutlet fileprivate var tasksScrollView: TasksScrollView?
    @IBOutlet fileprivate var listSegmentedControl: NSSegmentedControl?
    
    var appWireframe: AppWireframe?
    var tasksPresenter: TasksPresenterInput?
	
	override func awakeFromNib() {
		view.layer = CALayer()
		view.wantsLayer = true
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		registerForNotifications()
        listSegmentedControl!.selectedSegment = TaskTypeSelection().lastType().rawValue
        
        calendarScrollView!.didSelectDay = { [weak self] (day: Day) in
            self?.tasksPresenter?.reloadTasksOnDay(day, listType: ListType(rawValue: (self?.listSegmentedControl!.selectedSegment)!)!)
        }
        
        tasksScrollView!.didRemoveRow = { [weak self] (row: Int) in
            RCLogO("Remove item at row \(row)")
            if row >= 0 {
                self?.tasksPresenter!.removeTaskAtRow(row)
                self?.tasksScrollView!.removeTaskAtRow(row)
            }
        }
        tasksScrollView!.didAddRow = { [weak self] (row: Int) -> Void in
            RCLogO("Add item after row \(row)")
            if row >= 0 {
                self?.tasksPresenter!.insertTaskAfterRow(row)
            }
        }
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
        tasksPresenter!.refreshUI()
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self)
	}
}

extension TasksViewController {
	
	@IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        let listType = ListType(rawValue: sender.selectedSegment)!
        TaskTypeSelection().setType(listType)
        if let selectedDay = calendarScrollView!.selectedDay {
            tasksPresenter!.reloadTasksOnDay(selectedDay, listType: listType)
        }
	}
    
    @IBAction func handleSettingsButton (_ sender: NSButton) {
        appWireframe!.flipToSettingsController()
    }
    
    @IBAction func handleQuitAppButton (_ sender: NSButton) {
        NSApplication.shared().terminate(nil)
    }
}

extension TasksViewController: TasksPresenterOutput {
    
    func showLoadingIndicator (_ show: Bool) {
        
    }
    
    func showMessage (_ message: MessageViewModel) {
        
        appWireframe?.presentMessage(message, intoSplitView: splitView!)
        appWireframe?.messageViewController.didPressButton = tasksPresenter?.messageButtonDidPress
    }
    
    func showDates (_ weeks: [Week]) {
        
        calendarScrollView?.weeks = weeks
        calendarScrollView?.reloadData()
    }
    
    func showTasks (_ tasks: [Task], listType: ListType) {
        
        tasksScrollView!.listType = listType
        tasksScrollView!.tasks = tasks
        tasksScrollView!.reports = nil
        tasksScrollView!.reloadData()
        tasksScrollView!.isHidden = false
    }
    
    func showReports (_ reports: [Report], listType: ListType) {
        
        tasksScrollView!.listType = listType
        tasksScrollView!.tasks = nil
        tasksScrollView!.reports = reports
        tasksScrollView!.reloadData()
        tasksScrollView!.isHidden = false
    }
    
    func selectDay (_ day: Day) {
        calendarScrollView!.selectDay(day)
    }
    
    func presentNewTaskController() {
        
        splitView!.isHidden = true
        appWireframe!.removeMessage()
        
        appWireframe!.presentNewTaskController()
        appWireframe!.newTaskViewController.date = Date()
        appWireframe!.newTaskViewController.onOptionChosen = { [weak self] (taskData: TaskCreationData) -> Void in
            self?.tasksPresenter!.insertTaskWithData(taskData)
            self?.tasksPresenter!.updateNoTasksState()
            self?.tasksPresenter!.reloadData()
            self?.appWireframe!.removeNewTaskController()
            self?.splitView!.isHidden = false
        }
        appWireframe!.newTaskViewController.onCancelChosen = { [weak self] in
            self?.appWireframe?.removeNewTaskController()
            self?.splitView?.isHidden = false
            self?.tasksPresenter?.updateNoTasksState()
        }
    }
}

extension TasksViewController {
	
	func registerForNotifications() {
		
		NotificationCenter.default.addObserver(self,
			selector: #selector(TasksViewController.handleNewTaskAdded(_:)),
			name: NSNotification.Name(rawValue: kNewTaskWasAddedNotification),
			object: nil)
	}
	
	func handleNewTaskAdded (_ notif: Notification) {
        tasksPresenter?.reloadData()
	}
}

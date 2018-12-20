//
//  TasksViewController.swift
//  Jirassic
//
//  Created by Baluta Cristian on 28/03/15.
//  Copyright (c) 2015 Cristian Baluta. All rights reserved.
//

import Cocoa

class TasksViewController: NSViewController {
	
	@IBOutlet private var splitView: NSSplitView!
	@IBOutlet private var calendarScrollView: CalendarScrollView!
	private var tasksScrollView: TasksScrollView?
    @IBOutlet private var listSegmentedControl: NSSegmentedControl!
    @IBOutlet private var butRefresh: NSButton!
    @IBOutlet private var butSettings: NSButton!
    @IBOutlet private var butWarning: NSButton!
    @IBOutlet private var butWarningRightConstraint: NSLayoutConstraint!
    @IBOutlet private var butQuit: NSButton!
    @IBOutlet private var butMinimize: NSButton!
    @IBOutlet private var loadingTasksIndicator: NSProgressIndicator!
    @IBOutlet private var syncIndicator: NSProgressIndicator!
    
    weak var appWireframe: AppWireframe?
    var presenter: TasksPresenterInput?
    /// Property to keep a reference to the active cell rect
    private var rectToDisplayPopoverAt: NSRect?
    private var activePopover: NSPopover?
	
	override func awakeFromNib() {
        super.awakeFromNib()
		createLayer()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
		registerForNotifications()
        listSegmentedControl!.selectedSegment = TaskTypeSelection().lastType().rawValue
        hideControls(false)
        
        calendarScrollView!.didSelectDay = { [weak self] (day: Day) in
            guard let strongSelf = self else {
                return
            }
            let selectedListType = ListType(rawValue: strongSelf.listSegmentedControl!.selectedSegment)!
            strongSelf.presenter!.reloadTasksOnDay(day, listType: selectedListType)
        }
    }
	
	override func viewDidAppear() {
		super.viewDidAppear()
        presenter!.initUI()
	}
	
    deinit {
        RCLog(self)
		NotificationCenter.default.removeObserver(self)
	}
    
    private func hideControls (_ hide: Bool) {
        butSettings.isHidden = hide
        butRefresh.isHidden = remoteRepository == nil ? true : hide
        butWarning.isHidden = hide
        butQuit.isHidden = hide
        butMinimize.isHidden = hide
        listSegmentedControl.isHidden = hide
    }
}

extension TasksViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

extension TasksViewController {
	
	@IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        let listType = ListType(rawValue: sender.selectedSegment)!
        TaskTypeSelection().setType(listType)
        if let selectedDay = calendarScrollView!.selectedDay {
            presenter!.reloadTasksOnDay(selectedDay, listType: listType)
        }
	}
    
    @IBAction func handleRefreshButton (_ sender: NSButton) {
        presenter!.syncData()
    }
    
    @IBAction func handleSettingsButton (_ sender: NSButton) {
        appWireframe!.flipToSettingsController()
    }
    
    @IBAction func handleWarningButton (_ sender: NSButton) {
        RCPreferences<LocalPreferences>().set(SettingsTab.input.rawValue, forKey: .settingsActiveTab)
        appWireframe!.flipToSettingsController()
    }
    
    @IBAction func handleQuitAppButton (_ sender: NSButton) {
        NSApplication.shared.terminate(nil)
    }
    
    @IBAction func handleMinimizeAppButton (_ sender: NSButton) {
        AppDelegate.sharedApp().menu.triggerClose()
    }
}

extension TasksViewController: TasksPresenterOutput {
    
    func showLoadingIndicator (_ show: Bool) {
        
        butRefresh.isHidden = remoteRepository == nil ? true : show
        butWarningRightConstraint.constant = butRefresh.isHidden ? 0 : 22
        if show {
            loadingTasksIndicator.isHidden = false
            loadingTasksIndicator.startAnimation(nil)
        } else {
            loadingTasksIndicator.stopAnimation(nil)
            loadingTasksIndicator.isHidden = true
        }
    }
    
    func showWarning (_ show: Bool) {
        butWarning.isHidden = !show
    }
    
    func showMessage (_ message: MessageViewModel) {
        
        let controller = appWireframe!.presentPlaceholder(message, intoSplitView: splitView!)
        controller.didPressButton = {
            self.presenter?.messageButtonDidPress()
        }
    }

    func showProjects (_ projects: [Project]) {

        var frame = splitView!.subviews[SplitViewColumn.projects.rawValue].frame
        frame.origin = NSPoint.zero
        let projectsView = ProjectsViewController.instantiateFromStoryboard("Projects")
        projectsView.view.frame = frame
        splitView.subviews[SplitViewColumn.projects.rawValue].addSubview(projectsView.view)
        projectsView.view.constrainToSuperview()
    }

    func showCalendar (_ weeks: [Week]) {
        
        calendarScrollView.weeks = weeks
        calendarScrollView.reloadData()
    }
    
    func showTasks (_ tasks: [Task]) {
        
        let dataSource = TasksDataSource(tasks: tasks)
        
        var frame = splitView!.subviews[SplitViewColumn.tasks.rawValue].frame
        frame.origin = NSPoint.zero
        let scrollView = TasksScrollView(dataSource: dataSource, listType: .allTasks)
        scrollView.frame = frame
        splitView.subviews[SplitViewColumn.tasks.rawValue].addSubview(scrollView)
        scrollView.constrainToSuperview()
        scrollView.didClickAddRow = { [weak self] (row, rect) in
            RCLogO("Add item after row \(row)")
            if row >= 0 {
                self?.rectToDisplayPopoverAt = rect ?? self?.tasksScrollView?.frameOfCell(atRow: row)
                self?.presenter!.insertTask(after: row)
            }
        }
        scrollView.didClickRemoveRow = { [weak self] row in
            RCLogO("Remove item at row \(row)")
            if row >= 0 {
                self?.presenter!.removeTask(at: row)
                self?.tasksScrollView!.removeTask(at: row)
            }
        }
        scrollView.didClickCloseDay = { [weak self] (tasks, shouldSaveToJira) in
            self?.presenter!.closeDay(shouldSaveToJira: shouldSaveToJira)
        }
        
        scrollView.reloadData()
        tasksScrollView = scrollView
    }
    
    func showReports (_ reports: [Report], numberOfDays: Int, type: ListType) {
        
        let dataSource = ReportsDataSource(reports: reports, numberOfDays: numberOfDays)
        
        var frame = splitView.subviews[SplitViewColumn.tasks.rawValue].frame
        frame.origin = NSPoint.zero
        let scrollView = TasksScrollView(dataSource: dataSource, listType: type)
        scrollView.frame = frame
        splitView!.subviews[SplitViewColumn.tasks.rawValue].addSubview(scrollView)
        scrollView.constrainToSuperview()
        scrollView.reloadData()
        scrollView.didChangeSettings = { [weak self] in
            if let strongSelf = self {
                strongSelf.handleSegmentedControl(strongSelf.listSegmentedControl)
            }
        }
        scrollView.didClickCopyMonthlyReport = { asHtml in
            var string = ""
            let interactor = CreateMonthReport()
            if asHtml {
                string = interactor.htmlReports(dataSource.reports)
            } else {
                let joined = interactor.joinReports(dataSource.reports)
                string = joined.notes + "\n\n" + joined.totalDuration.secToHoursAndMin
            }
            NSPasteboard.general.clearContents()
            NSPasteboard.general.writeObjects([string as NSPasteboardWriting])
        }
        
        tasksScrollView = scrollView
    }
    
    func removeTasksController() {
        
        if tasksScrollView != nil {
            tasksScrollView?.removeFromSuperview()
            tasksScrollView = nil
        }
    }
    
    func selectDay (_ day: Day) {
        calendarScrollView.selectDay(day)
    }
    
    func presentNewTaskController (date: Date) {
        
        let popover = NSPopover()
        let controller = NewTaskViewController.instantiateFromStoryboard("Components")
        controller.onSave = { [weak self] (taskData: TaskCreationData) -> Void in
            if let strongSelf = self {
                strongSelf.presenter!.insertTaskWithData(taskData)
                strongSelf.presenter!.updateNoTasksState()
                strongSelf.presenter!.reloadData()
                popover.performClose(nil)
            }
        }
        controller.onCancel = { [weak self] in
            if let strongSelf = self {
                popover.performClose(nil)
                strongSelf.activePopover = nil
                strongSelf.presenter!.updateNoTasksState()
            }
        }
        popover.contentViewController = controller
        popover.show(relativeTo: rectToDisplayPopoverAt!, of: self.tasksScrollView!.view(), preferredEdge: NSRectEdge.maxY)
        // Add data after popover is presented
        controller.dateStart = nil// TODO Add scrum start date when around scrum date
        controller.dateEnd = date
        activePopover = popover
    }

    func presentEndDayController (date: Date, tasks: [Task]) {

        splitView.isHidden = true
        appWireframe!.removePlaceholder()
        hideControls(true)

        let controller = appWireframe!.presentEndDayController(date: date, tasks: tasks)
        controller.onSave = { [weak self] in
            if let strongSelf = self {
                strongSelf.appWireframe!.removeEndDayController()
                strongSelf.splitView.isHidden = false
                strongSelf.hideControls(false)
                strongSelf.presenter!.reloadData()
            }
        }
        controller.onCancel = { [weak self] in
            if let strongSelf = self {
                strongSelf.appWireframe!.removeEndDayController()
                strongSelf.splitView.isHidden = false
                strongSelf.hideControls(false)
                strongSelf.presenter!.updateNoTasksState()
            }
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
	
	@objc func handleNewTaskAdded (_ notif: Notification) {
        presenter!.reloadData()
	}
}

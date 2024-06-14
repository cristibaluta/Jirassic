//
//  MainViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa
import RCPreferences
import RCLog

class MainViewController: NSViewController {
    
    @IBOutlet private var splitView: NSSplitView!
    @IBOutlet private var splitTopView: NSView!
    @IBOutlet private var splitBottomView: NSView!
    @IBOutlet private var splitTopViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var listSegmentedControl: NSSegmentedControl!
    @IBOutlet private var syncIndicator: NSProgressIndicator!
    @IBOutlet private var butRefresh: NSButton!
    @IBOutlet private var butSettings: NSButton!
    @IBOutlet private var butWarning: NSButton!
    @IBOutlet private var butWarningRightConstraint: NSLayoutConstraint!
    @IBOutlet private var butQuit: NSButton!
    @IBOutlet private var butMinimize: NSButton!
    
    private var calendarViewController: CalendarViewController?
    private var tasksViewController: TasksViewController?
    private var reportsViewController: ReportsViewController?
    private var projectsViewController: ProjectsViewController?
    
    weak var appWireframe: AppWireframe?
    var presenter: MainPresenterInput?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        createLayer()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForNotifications()
        hideControls(false)
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        presenter!.viewDidAppear()
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

extension MainViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

extension MainViewController {
    
    @IBAction func handleSegmentedControl (_ sender: NSSegmentedControl) {
        let listType = ListType(rawValue: sender.selectedSegment)!
        presenter!.select(listType: listType)
    }
    
    @IBAction func handleRefreshButton (_ sender: NSButton) {
//        presenter!.syncData()
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

extension MainViewController: MainPresenterOutput {
    
    func select(listType: ListType) {
        listSegmentedControl!.selectedSegment = listType.rawValue
    }
    
    func showLoadingIndicator (_ show: Bool) {
        
        butRefresh.isHidden = remoteRepository == nil ? true : show
        butWarningRightConstraint.constant = butRefresh.isHidden ? 0 : 22
//        if show {
//            loadingTasksIndicator.isHidden = false
//            loadingTasksIndicator.startAnimation(nil)
//        } else {
//            loadingTasksIndicator.stopAnimation(nil)
//            loadingTasksIndicator.isHidden = true
//        }
    }
    
    func showWarning (_ show: Bool) {
        butWarning.isHidden = !show
    }
    
    func showMessage (_ message: MessageViewModel) {
        
        let controller = appWireframe!.presentPlaceholder(message, in: self.view)
        controller.didPressButton = {
//            self.presenter?.messageButtonDidPress()
        }
    }
    
    func showCalendar() {
        
        guard calendarViewController == nil else {
            return
        }
        splitTopViewHeightConstraint.constant = 90
        
        let controller = CalendarViewController.instantiateFromStoryboard("Calendar")
        let presenter = CalendarPresenter()
        let interactor = CalendarInteractor()

        presenter.ui = controller
        presenter.interactor = interactor
        interactor.presenter = presenter
        controller.presenter = presenter
        controller.appWireframe = appWireframe
        
        splitTopView.addSubview(controller.view)
        self.addChild(controller)
        controller.view.constrainToSuperview()

        calendarViewController = controller
        calendarViewController!.didChangeDay = { [weak self] day in
            if let controller = self?.tasksViewController {
                controller.presenter?.reloadTasksOnDay(day)
            } else if let controller = self?.reportsViewController {
                controller.presenter?.reloadReportsInDay(day)
            }
        }
        calendarViewController!.didChangeMonth = { [weak self] date in
            guard let controller = self?.reportsViewController else {
                return
            }
            controller.presenter?.reloadReportsInMonth(date)
        }
    }
    
    func showTasks() {
        
        let controller = TasksViewController.instantiateFromStoryboard("Tasks")
        let presenter = TasksPresenter()
        let interactor = TasksInteractor()

        presenter.ui = controller
        presenter.interactor = interactor
        presenter.appWireframe = appWireframe
        interactor.presenter = presenter
        controller.presenter = presenter
        controller.appWireframe = appWireframe
        
        splitBottomView.addSubview(controller.view)
        self.addChild(controller)
        controller.view.constrainToSuperview()

        tasksViewController = controller
        
        guard let selectedDay = calendarViewController!.selectedDay else {
            return
        }
        controller.presenter?.reloadTasksOnDay(selectedDay)
    }
    
    func showReports () {
        
        let controller = ReportsViewController.instantiateFromStoryboard("Reports")
        let presenter = ReportsPresenter()
        let interactor = TasksInteractor()

        presenter.ui = controller
        presenter.interactor = interactor
        presenter.appWireframe = appWireframe
        interactor.presenter = presenter
        controller.presenter = presenter
        controller.appWireframe = appWireframe
        
        splitBottomView.addSubview(controller.view)
        self.addChild(controller)
        controller.view.constrainToSuperview()

        reportsViewController = controller
    }
    
    func showProjects() {

        let controller = ProjectsViewController.instantiateFromStoryboard("Projects")
        let presenter = ProjectsPresenter()
        let interactor = ProjectsInteractor()

        presenter.ui = controller
        presenter.interactor = interactor
        interactor.presenter = presenter
        controller.presenter = presenter
        controller.appWireframe = appWireframe

        splitBottomView.addSubview(controller.view)
        self.addChild(controller)
        controller.view.constrainToSuperview()
        
        projectsViewController = controller
    }
    
    func removeCalendar() {
        guard let controller = calendarViewController else {
            return
        }
        controller.removeFromSuperview()
        controller.removeFromParent()
        calendarViewController = nil
        splitTopViewHeightConstraint.constant = 10
    }
    func removeTasks() {
        guard let controller = tasksViewController else {
            return
        }
        controller.removeFromSuperview()
        controller.removeFromParent()
        tasksViewController = nil
    }
    func removeReports() {
        guard let controller = reportsViewController else {
            return
        }
        controller.removeFromSuperview()
        controller.removeFromParent()
        reportsViewController = nil
    }
    func removeProjects() {
        guard let controller = projectsViewController else {
            return
        }
        controller.removeFromSuperview()
        controller.removeFromParent()
        projectsViewController = nil
    }
    
    func tasksDidClear() {
        calendarViewController?.reloadData()
    }
}

extension MainViewController {
    
    func registerForNotifications() {
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(MainViewController.handleNewTaskAdded(_:)),
            name: NSNotification.Name(rawValue: kNewTaskWasAddedNotification),
            object: nil)
    }
    
    @objc func handleNewTaskAdded (_ notif: Notification) {
//        presenter!.reloadData()
    }
}

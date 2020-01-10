//
//  ReportsViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 27/12/2019.
//  Copyright © 2019 Imagin soft. All rights reserved.
//

import Cocoa
import RCLog

class ReportsViewController: NSViewController {
    
    @IBOutlet private var loadingTasksIndicator: NSProgressIndicator!
    private var tasksScrollView: TasksScrollView?
    
    weak var appWireframe: AppWireframe?
    var presenter: ReportsPresenterInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter!.viewDidLoad()
    }
    
    deinit {
        RCLog(self)
    }
}

extension ReportsViewController: ReportsPresenterOutput {
    
    func showLoadingIndicator (_ show: Bool) {
        
        if show {
            loadingTasksIndicator.isHidden = false
            loadingTasksIndicator.startAnimation(nil)
        } else {
            loadingTasksIndicator.stopAnimation(nil)
            loadingTasksIndicator.isHidden = true
        }
    }
    
    func showMessage (_ message: MessageViewModel) {
        
        let controller = appWireframe!.presentPlaceholder(message, in: self.view)
        controller.didPressButton = {
            self.presenter?.messageButtonDidPress()
        }
    }
    
    func showReports (_ reports: [Report], numberOfDays: Int) {
        
        let dataSource = ReportsDataSource(reports: reports, numberOfDays: numberOfDays)
        dataSource.didChangeSettings = { [weak self] in
            self?.presenter?.reloadLastSelectedMonth()
        }
        dataSource.didClickCopyMonthlyReport = { [weak self] asHtml in
            self?.presenter?.copyMonthlyReportsToClipboard(asHtml: asHtml)
        }

        let scrollView = TasksScrollView(dataSource: dataSource)
        self.view.addSubview(scrollView)
        scrollView.constrainToSuperview()
        scrollView.reloadData()

        tasksScrollView = scrollView
    }
    
    func removeReports() {
        
        if tasksScrollView != nil {
            tasksScrollView?.removeFromSuperview()
            tasksScrollView = nil
        }
    }
}

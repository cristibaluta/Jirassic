//
//  EndDayViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 05/02/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class EndDayViewController: NSViewController {

    @IBOutlet fileprivate var worklogTextView: NSTextView!
    @IBOutlet fileprivate var progressIndicator: NSProgressIndicator!

    var onSave: (() -> Void)?
    var onCancel: (() -> Void)?
    var presenter: EndDayPresenterInput?
    var date: Date?
    fileprivate let localPreferences = RCPreferences<LocalPreferences>()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter!.setup(date: date!)
    }

    @IBAction func handleCancelButton (_ sender: NSButton) {
        self.onCancel?()
    }

    @IBAction func handleSaveButton (_ sender: NSButton) {
        presenter?.save(jiraTempo: true, roundTime: true, worklog: worklogTextView.string)
    }
}

extension EndDayViewController: EndDayPresenterOutput {

    func showWorklog (_ worklog: String) {
        worklogTextView.string = worklog
    }

    func showProgressIndicator (_ show: Bool) {
        if show {
            progressIndicator.startAnimation(nil)
        } else {
            progressIndicator.stopAnimation(nil)
        }
    }
}

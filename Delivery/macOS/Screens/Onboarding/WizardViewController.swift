//
//  WizardViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 16/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

enum WizardStep: Int {
    case shell = 0
    case browser = 1
    case git = 2
    case calendar = 3
    case jira = 4
    case finished = 5
}

class WizardViewController: NSViewController {
    
    weak var appWireframe: AppWireframe?
    @IBOutlet private var titleLabel: NSTextField!
    @IBOutlet private var subtitleLabel: NSTextField!
    @IBOutlet private var containerView: NSView!
    @IBOutlet private var containerViewHeightConstrain: NSLayoutConstraint!
    private var contentView: NSView?
    @IBOutlet private var butSkip: NSButton!
    @IBOutlet private var levelIndicator: NSLevelIndicator!
    private let pref = RCPreferences<LocalPreferences>()
    private var step: WizardStep = WizardStep.shell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLayer()
        levelIndicator.maxValue = 5
        if let wizardStep = WizardStep(rawValue: self.pref.int(.wizardStep)) {
            goTo(step: wizardStep)
        }
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        removeCurrentContent()
    }

    deinit {
        RCLog("deinit")
    }
    
    func goTo (step: WizardStep) {

        removeCurrentContent()
        self.step = step
        levelIndicator.intValue = Int32(step.rawValue + 1)
        switch step {
        case .shell:
            titleLabel.stringValue = "Shell Support"
            subtitleLabel.stringValue = "Jirassic needs shell support to communicate with Git and the Browser.\nShell is accessed through the AppleScript which for security reasons you need to install manually."
            let applescriptView = WizardAppleScriptView.instantiateFromXib()
            applescriptView.titleLabel.stringValue = "Install ShellSupport.scpt"
            applescriptView.subtitle = "Go to jirassic.com, copy the install script and run it in your Terminal. We'll wait!"
            applescriptView.scriptName = kShellSupportScriptName
            applescriptView.onSkip = { [weak self] in
                if let wself = self {
                    wself.handleNextButton(wself.butSkip)
                }
            }
            containerView.addSubview(applescriptView)
            applescriptView.constrainToSuperview()
            contentView = applescriptView
            containerViewHeightConstrain.constant = 114
            break
        case .browser:
            titleLabel.stringValue = "Browser Support"
            subtitleLabel.stringValue = "Jirassic will be able to read the url of the active browser and it will detect when you do code reviews and when you waste time on social media."
            let applescriptView = WizardAppleScriptView.instantiateFromXib()
            applescriptView.titleLabel.stringValue = "Install BrowserSupport.scpt"
            applescriptView.subtitle = "Go to jirassic.com, copy the install script and run it in your Terminal. We'll wait!"
            applescriptView.scriptName = kBrowserSupportScriptName
            applescriptView.onSkip = { [weak self] in
                if let wself = self {
                    wself.handleNextButton(wself.butSkip)
                }
            }
            containerView.addSubview(applescriptView)
            applescriptView.constrainToSuperview()
            contentView = applescriptView
            containerViewHeightConstrain.constant = 114
            break
        case .git:
            titleLabel.stringValue = "Git"
            subtitleLabel.stringValue = "Include the git commits in the reports, to help you write more accurate worklogs. Chose the user and project you work on!"
            let gitView = WizardGitView.instantiateFromXib()
            gitView.onSkip = { [weak self] in
                if let wself = self {
                    wself.handleNextButton(wself.butSkip)
                }
            }
            containerView.addSubview(gitView)
            gitView.constrainToSuperview()
            contentView = gitView
            containerViewHeightConstrain.constant = 114
            break
        case .calendar:
            titleLabel.stringValue = "Calendar.app"
            subtitleLabel.stringValue = "Includes calendar events in the reports as meetings."
            let calendarView = WizardCalendarView.instantiateFromXib()
            calendarView.onSkip = { [weak self] in
                if let wself = self {
                    wself.handleNextButton(wself.butSkip)
                }
            }
            containerView.addSubview(calendarView)
            calendarView.constrainToSuperview()
            contentView = calendarView
            containerViewHeightConstrain.constant = 200
            break
        case .jira:
            titleLabel.stringValue = "Jira Tempo"
            subtitleLabel.stringValue = "Jirassic can post your worklogs directly to Jira Tempo, very convenient and very fast. Please login then select the project and issue you want to post the worklogs to."
            let jiraView = WizardJiraView.instantiateFromXib()
            jiraView.onSkip = { [weak self] in
                if let wself = self {
                    wself.handleNextButton(wself.butSkip)
                }
            }
            containerView.addSubview(jiraView)
            jiraView.constrainToSuperview()
            contentView = jiraView
            containerViewHeightConstrain.constant = 114
            butSkip.title = "Finish setup"
            break
        case .finished:
            self.handleNextButton(self.butSkip)
            break
        }
    }

    private func removeCurrentContent() {
        if let view = contentView {
            view.removeFromSuperview()
            if let v = view as? WizardAppleScriptView {
                v.invalidate()
            }
            contentView = nil
        }
    }
    
    @IBAction func handleNextButton (_ sender: NSButton) {
        if let nextStep = WizardStep(rawValue: step.rawValue + 1) {
            goTo(step: nextStep)
            pref.set(nextStep.rawValue, forKey: .wizardStep)
        } else {
            handleSkipButton(sender)
        }
    }
    
    @IBAction func handleSkipButton (_ sender: NSButton) {
        pref.set(WizardStep.finished.rawValue, forKey: .wizardStep)
        appWireframe!.flipToTasksController()
    }
    
    @IBAction func handleQuitAppButton (_ sender: NSButton) {
        NSApplication.shared.terminate(nil)
    }
    
    @IBAction func handleMinimizeAppButton (_ sender: NSButton) {
        AppDelegate.sharedApp().menu.triggerClose()
    }
}

extension WizardViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

//
//  WizardViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 16/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

enum WizardStep: Int, CaseIterable {
    case shell = 0
    case browser = 1
    case git = 2
    case calendar = 3
    case jira = 4
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
    private let steps: [WizardStep] = [.shell, .browser, .git, .calendar, .jira]
    private var stepsUnseen: [WizardStep] {
        let stepsSaved: [Int] = pref.get(.wizardSteps)
        let stepsSeen: [WizardStep] = stepsSaved.map({ WizardStep(rawValue: $0)! })
        let unseen: [WizardStep] = steps.filter({ !stepsSeen.contains($0) })
        return unseen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createLayer()
        levelIndicator.maxValue = Double(WizardStep.allCases.count)
        if let wizardStep = stepsUnseen.first {
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
            subtitleLabel.stringValue = "Jirassic needs shell support to communicate with Git and the Browser.\nThe shell is accessed through an AppleScript which for security reasons you need to install manually."
            let applescriptView = WizardAppleScriptView.instantiateFromXib()
            applescriptView.titleLabel.stringValue = "Install ShellSupport.scpt"
            applescriptView.subtitle = "Go to jirassic.com, copy the install script and run it in your Terminal.app. We'll wait!"
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
            subtitleLabel.stringValue = "Include git commits in reports, to help you write more accurate worklogs. Chose the users and projects you want to track!"
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
            subtitleLabel.stringValue = "Include calendar events in the reports and treat them as meetings. Please enable and select the calendars you use!"
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
        var stepsUnseen = self.stepsUnseen
        let stepSeen = stepsUnseen.removeFirst()
        if let nextStep = stepsUnseen.first {
            goTo(step: nextStep)
            let stepsSaved: [Int] = pref.get(.wizardSteps)
            var stepsSeen: [WizardStep] = stepsSaved.map({ WizardStep(rawValue: $0)! })
            stepsSeen.append(stepSeen)
            stepsSeen.sort { (w1, w2) -> Bool in
                w1.rawValue < w2.rawValue
            }
            let stepsToSave: [Int] = stepsSeen.map({ $0.rawValue })
            pref.set(stepsToSave, forKey: .wizardSteps)
        } else {
            handleSkipButton(sender)
        }
    }
    
    @IBAction func handleSkipButton (_ sender: NSButton) {
        let stepsToSave: [Int] = WizardStep.allCases.map({ $0.rawValue })
        pref.set(stepsToSave, forKey: .wizardSteps)
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

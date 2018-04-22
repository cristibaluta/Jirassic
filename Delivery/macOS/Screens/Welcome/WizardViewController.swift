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
    case jira = 3
    case finished = 4
}

class WizardViewController: NSViewController {
    
    weak var appWireframe: AppWireframe?
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var subtitleLabel: NSTextField!
    @IBOutlet var containerView: NSView!
    var contentView: NSView?
    @IBOutlet var butSkip: NSButton!
    @IBOutlet var levelIndicator: NSLevelIndicator!
    private let localPreferences = RCPreferences<LocalPreferences>()
    private var step: WizardStep = WizardStep.shell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createLayer()
        if let wizardStep = WizardStep(rawValue: self.localPreferences.int(.wizardStep)) {
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
            localPreferences.set(nextStep.rawValue, forKey: .wizardStep)
        } else {
            handleSkipButton(sender)
        }
    }
    
    @IBAction func handleSkipButton (_ sender: NSButton) {
        localPreferences.set(WizardStep.finished.rawValue, forKey: .wizardStep)
        appWireframe!.flipToTasksController()
    }
}

extension WizardViewController: Animatable {
    
    func createLayer() {
        view.layer = CALayer()
        view.wantsLayer = true
    }
}

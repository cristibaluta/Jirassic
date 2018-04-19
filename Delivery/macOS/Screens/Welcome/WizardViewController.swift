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
            applescriptView.subtitleLabel.stringValue = "Go to this page, copy the script and run it in Terminal. We'll wait!"
            applescriptView.onSkip = {
                self.handleNextButton(self.butSkip)
            }
            containerView.addSubview(applescriptView)
            applescriptView.constrainToSuperview()
            contentView = applescriptView
            break
        case .browser:
            titleLabel.stringValue = "Browser Support"
            subtitleLabel.stringValue = "Jirassic will be able to read the url when the browser is active and it will detect when you do code reviews and when you waste time on social media."
            let applescriptView = WizardAppleScriptView.instantiateFromXib()
            applescriptView.titleLabel.stringValue = "Install BrowserSupport.scpt"
            applescriptView.subtitleLabel.stringValue = "Go to this page, copy the script and run it in Terminal. We'll wait!"
            applescriptView.onSkip = {
                self.handleNextButton(self.butSkip)
            }
            containerView.addSubview(applescriptView)
            applescriptView.constrainToSuperview()
            contentView = applescriptView
            break
        case .git:
            titleLabel.stringValue = "Git"
            subtitleLabel.stringValue = "Include the git commits in the reports, to help you write more accurate worklogs."
            let gitView = WizardGitView.instantiateFromXib()
            gitView.onSkip = {
                self.handleNextButton(self.butSkip)
            }
            containerView.addSubview(gitView)
            gitView.constrainToSuperview()
            contentView = gitView
            break
        case .jira:
            titleLabel.stringValue = "Jira Tempo"
            subtitleLabel.stringValue = "Jirassic can post your worklogs directly to Jira Tempo."
            let jiraView = WizardJiraView.instantiateFromXib()
            jiraView.onSkip = {
                self.handleNextButton(self.butSkip)
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
            contentView = nil
        }
    }
    
    @IBAction func handleNextButton (_ sender: NSButton) {
        if let nextStep = WizardStep(rawValue: step.rawValue + 1) {
            goTo(step: nextStep)
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

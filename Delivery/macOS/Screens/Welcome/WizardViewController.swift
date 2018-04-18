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
        if let wizardStep = WizardStep(rawValue: self.localPreferences.int(.wizardStep)) {
            goTo(step: wizardStep)
        }
    }
    
    func goTo (step: WizardStep) {
        self.step = step
        switch step {
        case .shell:
            titleLabel.stringValue = "Shell Support"
            subtitleLabel.stringValue = "Jirassic needs shell support to communicate with Git and the Browser.\nShell is accessed through the AppleScript which for security reasons you need to install manually."
            contentView = WizardAppleScriptView.instantiateFromXib()
            containerView.addSubview(contentView!)
            break
        case .browser:
            titleLabel.stringValue = "Browser Support"
            subtitleLabel.stringValue = "Jirassic will be able to read the url when the browser is active and it will detect when you do code reviews and when you waste time on social media."
            break
        case .git:
            titleLabel.stringValue = "Git"
            subtitleLabel.stringValue = "Create reports from git commits to help you write the worklogs."
            break
        case .jira:
            titleLabel.stringValue = "Jira Tempo"
            subtitleLabel.stringValue = "Jirassic can post your worklogs directly to Jira Tempo."
            break
        case .finished:
            break
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

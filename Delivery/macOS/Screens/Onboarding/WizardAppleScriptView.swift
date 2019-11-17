//
//  WizardAppleScriptView.swift
//  Jirassic
//
//  Created by Cristian Baluta on 18/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa
import RCLog

class WizardAppleScriptView: NSView {
    
    @IBOutlet var titleLabel: NSTextField!
    @IBOutlet var subtitleLabel: NSTextField!
    @IBOutlet var butLink: NSButton!
    @IBOutlet var butSkip: NSButton!
    @IBOutlet var progressIndicator: NSProgressIndicator!
    var onSkip: (() -> Void)?
    var scriptName: String? {
        didSet {
            handleTimer()
        }
    }
    var subtitle: String? {
        didSet {
            subtitleLabel.stringValue = subtitle ?? ""
        }
    }
    private var timer: Timer?
    private let scripts: AppleScriptProtocol = SandboxedAppleScript()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func invalidate() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        invalidate()
        RCLog("deinit")
    }
    
    @objc func handleTimer() {
        guard let scriptName = self.scriptName else {
            return
        }
        timer = WeakTimer.scheduledTimer(timeInterval: 1,
                                         target: self,
                                         repeats: true) { [weak self] timer in
                                            // Place your action code here.
                                            self?.scripts.getScriptVersion(script: scriptName, completion: { [weak self] scriptVersion in
                                                RCLog(scriptVersion)
                                                if scriptVersion != "" {
                                                    self?.progressIndicator.stopAnimation(nil)
                                                    self?.butLink.isHidden = true
                                                    self?.subtitleLabel.textColor = NSColor.green
                                                    self?.subtitleLabel.stringValue = "Installed successfully!"
                                                    self?.subtitleLabel.font = NSFont.systemFont(ofSize: 26)
                                                } else {
                                                    self?.progressIndicator.startAnimation(nil)
                                                    self?.butLink.isHidden = false
                                                    self?.subtitleLabel.textColor = NSColor.black
                                                    self?.subtitleLabel.stringValue = self?.subtitle ?? ""
                                                    self?.subtitleLabel.font = NSFont.systemFont(ofSize: 13)
                                                }
                                            })
        }
    }
    
    @IBAction func handleInstructionsButton (_ sender: NSButton) {
        #if APPSTORE
        NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #else
        NSWorkspace.shared.open( URL(string: "http://www.jirassic.com/#extensions")!)
        #endif
    }

    @IBAction func handleSkipButton (_ sender: NSButton) {
        onSkip?()
    }
}

final class WeakTimer {
    
    fileprivate weak var timer: Timer?
    fileprivate weak var target: AnyObject?
    fileprivate let action: (Timer) -> Void
    
    fileprivate init(timeInterval: TimeInterval,
                     target: AnyObject,
                     repeats: Bool,
                     action: @escaping (Timer) -> Void) {
        self.target = target
        self.action = action
        self.timer = Timer.scheduledTimer(timeInterval: timeInterval,
                                          target: self,
                                          selector: #selector(fire),
                                          userInfo: nil,
                                          repeats: repeats)
    }
    
    class func scheduledTimer(timeInterval: TimeInterval,
                              target: AnyObject,
                              repeats: Bool,
                              action: @escaping (Timer) -> Void) -> Timer {
        return WeakTimer(timeInterval: timeInterval,
                         target: target,
                         repeats: repeats,
                         action: action).timer!
    }
    
    @objc fileprivate func fire(timer: Timer) {
        if target != nil {
            action(timer)
        } else {
            timer.invalidate()
        }
    }
}

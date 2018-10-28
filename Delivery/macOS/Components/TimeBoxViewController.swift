//
//  TimeBoxViewController.swift
//  Jirassic
//
//  Created by Cristian Baluta on 27/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class TimeBoxViewController: NSViewController {

    @IBOutlet private weak var timeTextField: NSTextField!
    @IBOutlet private weak var instructionsTextField: NSTextField!
    @IBOutlet private weak var disclosureButton: NSButton!
    var didCancel: (() -> Void)?
    var didSave: (() -> Void)?
    
    private var partialValue = ""
    private var isEditing = false
    private var wasEdited = false
    private let predictor = PredictiveTimeTyping()
    
    var stringValue: String {
        get {
            return timeTextField.stringValue
        }
        set {
            timeTextField.stringValue = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disclosureButton.state = .on
        instructionsTextField.stringValue = "Predictive Time Typing (use digits and backspace):\n • First digit if between 2 and 9 means AM hours.\n • Leaving minutes empty, defaults to 00.\n • Last digit replaces itself, no need to delete."
    }
}

extension TimeBoxViewController {
    
    @IBAction func handleCancelButton (_ sender: NSButton) {
        didCancel?()
    }
    
    @IBAction func handleSaveButton (_ sender: NSButton) {
        didSave?()
    }
    
    @IBAction func handleDisclosureButton (_ sender: NSButton) {
        instructionsTextField.stringValue = sender.state == .off ? "" : "Predictive time typing:\n • First digit between 2 and 9 means AM.\n • Leaving minutes empty defaults to 00.\n • Last digit replaces itself."
    }
}

extension TimeBoxViewController: NSTextFieldDelegate {
    
    public func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        isEditing = true
        partialValue = stringValue
        return true
    }
    
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if wasEdited {
            wasEdited = false
        }
        return true
    }
    
    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        
        // Detect Enter key
        if wasEdited && commandSelector == #selector(NSResponder.insertNewline(_:)) {
            wasEdited = false
        }
        return false
    }
    
    override func controlTextDidChange (_ obj: Notification) {
        wasEdited = true
        let comps = stringValue.components(separatedBy: partialValue)
        // The difference between original string and new string is the last digit
        var newDigit = comps.last
        // If textfield was selected, entering a new digit replaces everything and it has the length 1
        if stringValue.count == 1 && partialValue.count > 2 {
            partialValue = ""
        }
        // Detect backspace
        else if comps.count == 1 && partialValue != "" {
            newDigit = nil
        }
        partialValue = predictor.timeByAdding(newDigit ?? "", to: partialValue)
        stringValue = partialValue
    }
}

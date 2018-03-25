//
//  TimeBox.swift
//  Jirassic
//
//  Created by Cristian Baluta on 19/03/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class TimeBox: NSBox {
    
    private var timeTextField: NSTextField?
    
    init() {
        super.init(frame: NSRect.zero)
        stringValue = ""
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.borderType = .lineBorder//.noBorder
        self.borderColor = NSColor.white
        self.fillColor = NSColor.white
        
        timeTextField = NSTextField()
        timeTextField?.font = NSFont.boldSystemFont(ofSize: 10)
        timeTextField?.textColor = NSColor.darkGray//AppDelegate.sharedApp().theme.textColor
        timeTextField?.backgroundColor = NSColor.white
        timeTextField?.drawsBackground = true
        timeTextField?.alignment = .center
        timeTextField?.focusRingType = .none
        timeTextField?.placeholderString = "00:00"
        timeTextField?.delegate = self
        
        self.addSubview(timeTextField!)
        
        timeTextField?.translatesAutoresizingMaskIntoConstraints = false
        let viewsDictionary = ["view": timeTextField!]
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-(-5)-[view]-(-5)-|", options: [], metrics: nil, views: viewsDictionary))
        self.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-(-3)-[view]-(-5)-|", options: [], metrics: nil, views: viewsDictionary))
    }
    
    var stringValue: String {
        get {
            return timeTextField!.stringValue
        }
        set {
            timeTextField!.stringValue = newValue
        }
    }
    
    var isEditable: Bool = true {
        didSet {
            timeTextField?.isEditable = isEditable
        }
    }
    
    var isEditing = false
    var wasEdited = false
    var didEndEditing: (() -> Void)?
    
    private var partialValue = ""
    private let predictor = PredictiveTimeTyping()
}

extension TimeBox: NSTextFieldDelegate {

    public func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        isEditing = true
        partialValue = stringValue
        self.borderColor = NSColor.darkGray
        timeTextField?.textColor = NSColor.black

        return true
    }

    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if wasEdited {
            wasEdited = false
            didEndEditing?()
        }
        self.borderColor = NSColor.white
        timeTextField?.textColor = NSColor.darkGray

        return true
    }

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {

        // Detect Enter key
        if wasEdited && commandSelector == #selector(NSResponder.insertNewline(_:)) {
            didEndEditing?()
            wasEdited = false
        }
        return false
    }

//    override func controlTextDidBeginEditing (_ obj: Notification) {
//        isEditing = true
//        partialValue = stringValue
//        self.borderColor = NSColor.darkGray
//        timeTextField?.textColor = NSColor.black
//    }

    override func controlTextDidChange (_ obj: Notification) {
        wasEdited = true
        let comps = stringValue.components(separatedBy: partialValue)
        let newDigit = (comps.count == 1 && partialValue != "") ? "" : comps.last
        partialValue = predictor.timeByAdding(newDigit!, to: partialValue)
        stringValue = partialValue
    }
    
//    override func controlTextDidEndEditing (_ obj: Notification) {
//        if wasEdited {
//            wasEdited = false
//            didEndEditing?()
//        }
//        self.borderColor = NSColor.white
//        timeTextField?.textColor = NSColor.darkGray
//    }
}

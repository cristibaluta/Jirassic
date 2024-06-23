//
//  EditableTimeBox.swift
//  Jirassic
//
//  Created by Cristian Baluta on 28/10/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Cocoa

class EditableTimeBox: TimeBox {
    
    var isEditing = false
    var wasEdited = false
    var didBeginEditing: (() -> Void)?
    var didEndEditing: (() -> Void)?
    
    private var partialValue = ""
    private let predictor = PredictiveTimeTyping()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timeTextField?.delegate = self
//        backgroundBox?.fillColor = .darkGray
    }
}

extension EditableTimeBox: NSTextFieldDelegate {
    
    public func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        isEditing = true
        partialValue = stringValue
//        backgroundBox?.borderColor = .darkGray
        timeTextField?.textColor = .black
        
        return true
    }
    
    public func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        if wasEdited {
            wasEdited = false
            didEndEditing?()
        }
//        backgroundBox?.borderColor = .white
        timeTextField?.textColor = .darkGray
        
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
    
    func controlTextDidChange (_ obj: Notification) {
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

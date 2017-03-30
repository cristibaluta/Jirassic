//
//  RCLog.swift
//
//  Created by Baluta Cristian on 12/08/2014.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import Foundation
import CoreGraphics

private var tracesDisabled = false
private var allowedClasses = [String]()
private var lastTracedMethod = ""

func RCLog (_ obj: Any, file: String = #file, line: Int = #line, function: String = #function) {
	traceFile(file, methodName: function, line: line, message: "\(obj)")
}

func RCLogO (_ message: Any?, file: String = #file, line: Int = #line, function: String = #function) {
	traceFile(file, methodName: function, line: line, message: "\(String(describing: message))")
}

func RCLogErrorO (_ message: Any?, file: String = #file, line: Int = #line, function: String = #function) {
	if message != nil {
		print("**ERROR:")
		traceFile(file, methodName: function, line: line, message: "\(String(describing: message))")
	}
}

func RCLogI (_ message: Int?, file: String = #file, line: Int = #line, function: String = #function) {
	traceFile(file, methodName: function, line: line, message: "\(String(describing: message))")
}

func RCLogF (_ message: Float?, file: String = #file, line: Int = #line, function: String = #function) {
	traceFile(file, methodName: function, line: line, message: "\(String(describing: message))")
}

func RCLogRect (_ message: CGRect?, file: String = #file, line: Int = #line, function: String = #function) {
	if message != nil {
		traceFile(file, methodName: function, line: line, message: "CGRect \(String(describing: message))")
	} else {
		traceFile(file, methodName: function, line: line, message: "\(String(describing: message))")
	}
}

func RCLogSize (_ message: CGSize?, file: String = #file, line: Int = #line, function: String = #function) {
	traceFile(file, methodName: function, line: line, message: "CGSize \(String(describing: message))")
}

func RCLogPoint (_ message: CGPoint?, file: String = #file, line: Int = #line, function: String = #function) {
	traceFile(file, methodName: function, line: line, message: "CGPoint \(String(describing: message))")
}

func RCLogThread (_ file: String = #file, line: Int = #line, function: String = #function) {
	let message = Thread.isMainThread ? "Log from Main Thread" : "Log from Secondary Thread"
	print("\((file as NSString).lastPathComponent):\(line): \(message)")
}


// MARK: Trace

@inline(__always) private func traceFile (_ file: String, methodName: String, line: Int, message: String) {
	
	if !tracesDisabled {
		if allowedClasses.count == 0 {
			_traceFile(file, methodName: methodName, line: line, message: message)
		} else {
			for c in allowedClasses {
				if c == (((file as NSString).lastPathComponent.components(separatedBy: ".") as NSArray).firstObject as! String) {
					_traceFile(file, methodName: methodName, line: line, message: message)
				}
			}
		}
	}
}

@inline(__always) private func _traceFile (_ file: String, methodName: String, line: Int, message: String) {
	
	let className = (file as NSString).lastPathComponent
	let prefix = lastTracedMethod == methodName ? className : "\n\(className):\(methodName)\n\(className)"
	
	print("\(prefix):\(line): \(message)")
	
    lastTracedMethod = methodName;
}

func disableTraces() {
	tracesDisabled = true
}

/**!
 *  Chose the classes you want to see the traces from
 *  @param arr is an array of strings that represent the file names.
 *  Call this method as many times as you like.
 *  If you don't specify any all traces are sent to the output
 **/
func allowClasses (_ arr: Array<String>) {
    allowedClasses += arr
}

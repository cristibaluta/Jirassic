//
//  RCLog.swift
//
//  Created by Baluta Cristian on 12/08/2014.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import Foundation

func RCLog (message: String, file: String = __FILE__, line: Int = __LINE__) {
	println("\(file.lastPathComponent):\(line): \(message)")
}

func RCLogO (message: AnyObject?, file: String = __FILE__, line: Int = __LINE__) {
	println("\(file.lastPathComponent):\(line): \(message)")
}

func RCLogI (message: Int?, file: String = __FILE__, line: Int = __LINE__) {
	println("\(file.lastPathComponent):\(line): \(message)")
}

func RCLogF (message: Float?, file: String = __FILE__, line: Int = __LINE__) {
	println("\(file.lastPathComponent):\(line): \(message)")
}

func RCLogRect (message: CGRect?, file: String = __FILE__, line: Int = __LINE__) {
	if message != nil {
		println("\(file.lastPathComponent):\(line): CGRect\(message!)")
	} else {
		println("\(file.lastPathComponent):\(line): \(message)")
	}
}

func RCLogSize (message: CGSize?, file: String = __FILE__, line: Int = __LINE__) {
	println("\(file.lastPathComponent):\(line): \(message)")
}

func RCLogPoint (message: CGPoint?, file: String = __FILE__, line: Int = __LINE__) {
	println("\(file.lastPathComponent):\(line): \(message)")
}

func RCLogThread (file: String = __FILE__, line: Int = __LINE__) {
	let message = NSThread.isMainThread() ? "Log from Main Thread" : "Log from Secondary Thread"
	println("\(file.lastPathComponent):\(line): \(message)")
}

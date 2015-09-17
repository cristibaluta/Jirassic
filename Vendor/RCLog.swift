//
//  RCLog.swift
//
//  Created by Baluta Cristian on 12/08/2014.
//  Copyright (c) 2014 Baluta Cristian. All rights reserved.
//

import Foundation
import CoreGraphics

func RCLog (message: String, file: String = __FILE__, line: Int = __LINE__) {
	print("\((file as NSString).lastPathComponent):\(line): \(message)")
}

func RCLogO (message: AnyObject?, file: String = __FILE__, line: Int = __LINE__) {
	print("\((file as NSString).lastPathComponent):\(line): \(message)")
}

func RCLogI (message: Int?, file: String = __FILE__, line: Int = __LINE__) {
	print("\((file as NSString).lastPathComponent):\(line): \(message)")
}

func RCLogF (message: Float?, file: String = __FILE__, line: Int = __LINE__) {
	print("\((file as NSString).lastPathComponent):\(line): \(message)")
}

func RCLogRect (message: CGRect?, file: String = __FILE__, line: Int = __LINE__) {
	if message != nil {
		print("\((file as NSString).lastPathComponent):\(line): CGRect\(message!)")
	} else {
		print("\((file as NSString).lastPathComponent):\(line): \(message)")
	}
}

func RCLogSize (message: CGSize?, file: String = __FILE__, line: Int = __LINE__) {
	print("\((file as NSString).lastPathComponent):\(line): \(message)")
}

func RCLogPoint (message: CGPoint?, file: String = __FILE__, line: Int = __LINE__) {
	print("\((file as NSString).lastPathComponent):\(line): \(message)")
}

func RCLogThread (file: String = __FILE__, line: Int = __LINE__) {
	let message = NSThread.isMainThread() ? "Log from Main Thread" : "Log from Secondary Thread"
	print("\((file as NSString).lastPathComponent):\(line): \(message)")
}

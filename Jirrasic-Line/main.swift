//
//  main.swift
//  Jirrasic-Line
//
//  Created by Baluta Cristian on 25/11/15.
//  Copyright © 2015 Cristian Baluta. All rights reserved.
//
//#!/usr/bin/env swift
import Foundation

print("Hello, World!")

var args = Process.arguments[1..<Process.arguments.count]
//var name = join(" ", args)

print("Hello, \(args)")

let task = NSTask()
task.launchPath = "/usr/bin/say"
task.arguments = ["speaking Phrase"]
task.launch()
task.waitUntilExit()

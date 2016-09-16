//
//  main.swift
//  jirassic
//
//  Created by Baluta Cristian on 06/01/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

enum ArgType {
    case nr
    case notes
    case type
}

func printHelp() {
    print("jirassic cli 1.0 - (c)2016 Cristian Baluta")
    print("Usage:")
    print("     insert -nr <task number> -type <task type> -notes <notes>")
}

let localRepository = CoreDataRepository()
var remoteRepository: Repository?

let saveInteractor = TaskInteractor(data: localRepository)
let reader = ReadTasksInteractor(data: localRepository)
let currentTasks = reader.tasksInDay(Date())
if currentTasks.count == 0 {
    let startDayMark = Task(dateEnd: Date(hour: 9, minute: 0), type: TaskType.startDay)
    saveInteractor.saveTask(startDayMark)
}

// Insert the task
var arguments = ProcessInfo.processInfo.arguments
arguments.remove(at: 0)

guard arguments.count > 0 else {
    printHelp()
    exit(0)
}

func insert (_ arguments: [String]) {
    
    var argType: ArgType?
    var taskNumber: String?
    var taskType = TaskType.issue
    var notes: String?
    
    for arg in arguments {
        if arg.hasPrefix("-") {
            switch arg {
            case "-nr": argType = .nr
                break
            case "-notes": argType = .notes
                break
            case "-type": argType = .type
                break
            default:
                print("Unsupported argument \(arg). Did you meant something else?")
                break
            }
        } else if let argType = argType {
            switch argType {
            case .nr: taskNumber = arg
                break
            case .notes:
                if notes == nil {
                    notes = arg
                } else {
                    notes = "\(notes!) \(arg)"
                }
                break
            case .type:
                if let type = TaskType(rawValue: Int(arg)!) {
                    taskType = type
                }
                break
            }
        }
    }
    
    let task = Task(
        endDate: Date(),
        notes: notes,
        taskNumber: taskNumber,
        taskType: NSNumber(value: taskType.rawValue),
        taskId: String.random()
    )
    print(task)
    saveInteractor.saveTask(task)
    
    print(task.taskId)
}

let command = arguments.remove(at: 0)

switch command {
case "insert": insert(arguments)
    break
default:
    printHelp()
    break
}

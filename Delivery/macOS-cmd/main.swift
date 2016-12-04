//
//  main.swift
//  jirassic
//
//  Created by Baluta Cristian on 06/01/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

var shouldKeepRunning = true
let theRL = RunLoop.current
//while shouldKeepRunning && theRL.run(mode: .defaultRunLoopMode, before: .distantFuture) {}

enum ArgType {
    case nr
    case notes
    case type
}

func printHelp() {
    print("jirassic-cmd 16.12.24 - (c)2016 Imagin soft")
    print("Usage:")
    print("     list -date <yyyy.mm.dd>")
    print("     insert -nr <task number> -type <task type> -notes <notes>")
    print("     lunch <duration>  Duration in minutes")
}

let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
let libraryDirectory = urls.first!
let jirassicSandboxedAppSupportDir = libraryDirectory.appendingPathComponent("Containers/com.ralcr.Jirassic.osx/Data/Library/Application Support/Jirassic")
//print(urls)
//print(jirassicSandboxedAppSupportDir)
// /Users/Cristian/Library/Containers/com.ralcr.Jirassic.osx/Data/Library/Application%20Support/Jirassic/
// /Users/Cristian/Library/Application%20Support/Jirassic/
let localRepository: Repository! = CoreDataRepository(documentsDirectory: jirassicSandboxedAppSupportDir.path)
var remoteRepository: Repository?


let settings = SettingsInteractor().getAppSettings()
//print(currentTasks)


// Insert the task
var arguments = ProcessInfo.processInfo.arguments
//print(arguments)
arguments.remove(at: 0)

guard arguments.count > 0 else {
    printHelp()
    exit(0)
}

func list (dayOnDate date: Date) {
    let reader = ReadTasksInteractor(repository: localRepository)
    let tasks = reader.tasksInDay(date)
    for task in tasks {
        print(task.endDate.HHmm() + " " + task.notes!)
    }
}

func insert (_ arguments: [String]) {
    
    let reader = ReadTasksInteractor(repository: localRepository)
    let currentTasks = reader.tasksInDay(Date())
    guard currentTasks.count > 0 else {
        print("Working day was not started yet. Run jirassic start.")
        return
    }
    //    let startDayMark = Task(dateEnd: Date(hour: 9, minute: 0), type: TaskType.startDay)
    //    print(startDayMark)
    //    saveInteractor.saveTask(startDayMark)
    //}
    
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
        startDate: nil,
        endDate: Date(),
        notes: notes,
        taskNumber: taskNumber,
        taskType: taskType,
        objectId: String.random()
    )
    print(task)
    let saveInteractor = TaskInteractor(repository: localRepository)
    saveInteractor.saveTask(task)
    
    print(task.objectId)
}

let command = arguments.remove(at: 0)
print("command \(command)")
switch command {
    case "list":
        list (dayOnDate: Date())
        break
    case "insert": //insert(arguments)
        break
    default:
        printHelp()
        break
}

exit(0)

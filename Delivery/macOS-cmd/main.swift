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
    case taskNr
    case notes
}

func printHelp() {
    print("jirassic 16.12.24 - (c)2016 Imagin soft")
    print("Usage:")
    print("     list [yyyy.mm.dd] If date is missing list tasks from today")
    print("     reports [yyyy.mm.dd] If date is missing list reports from today")
    print("     insert -nr <task number> -notes <notes> -duration <mm>")
    print("     [scrum,lunch,meeting,nap,learning,coderev] <duration>  Duration in minutes")
    print("")
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


//let settings = localRepository!.settings()
//print(currentTasks)


// Insert the task
var arguments = ProcessInfo.processInfo.arguments
//print(arguments)
arguments.remove(at: 0)// First arg is the filepath and needs to be removed

guard arguments.count > 0 else {
    printHelp()
    exit(0)
}

func dayStarted() -> Bool {
    
    let reader = ReadTasksInteractor(repository: localRepository)
    let currentTasks = reader.tasksInDay(Date())
    guard currentTasks.count > 0 else {
        print("Working day was not started yet. Run jirassic start.")
        return false
    }
    return true
}

func list (dayOnDate date: Date) {
    let reader = ReadTasksInteractor(repository: localRepository)
    let tasks = reader.tasksInDay(date)
    for task in tasks {
        print(task.endDate.HHmm() + " " + task.notes!)
    }
}

func insertIssue (arguments: [String]) {
    
    guard dayStarted() else {
        return
    }
    
    var argType: ArgType?
    var taskNumber: String?
    let taskType = TaskType.issue
    var notes: String?
    
    for arg in arguments {
        if arg.hasPrefix("-") {
            switch arg {
                case "-nr": argType = .taskNr
                    break
                case "-notes": argType = .notes
                    break
                default:
                    print("Unsupported argument \(arg). Is it a typo?")
                    break
            }
        } else if let argType = argType {
            switch argType {
            case .taskNr: taskNumber = arg
                break
            case .notes:
                if notes == nil {
                    notes = arg
                } else {
                    notes = "\(notes!) \(arg)"
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

func insert (taskType taskTypeStr: String, arguments: [String]) {
    
    guard dayStarted() else {
        return
    }
    
    var task: Task?
    
    switch taskTypeStr {
    case "scrum": task = Task(subtype: .scrumEnd)
        break
    case "lunch": task = Task(subtype: .lunchEnd)
        break
    case "meeting": task = Task(subtype: .meetingEnd)
        break
    case "nap": task = Task(subtype: .napEnd)
        break
    case "learning": task = Task(subtype: .learningEnd)
        break
    case "coderev": task = Task(subtype: .coderevEnd)
        break
    default:
        print("Unsupported first argument \(taskTypeStr). It should be [task,scrum,meeting,nap,learning,coderev]")
        return
    }
    
    if let duration = arguments.first {
        if let d = Double(duration) {
            if d > 0 {
                task?.startDate = task?.endDate.addingTimeInterval(d)
            }
        }
    }
    
    print(task!)
    let saveInteractor = TaskInteractor(repository: localRepository)
    saveInteractor.saveTask(task!)
    
    print(task!.objectId)
}

let command = arguments.remove(at: 0)
print("command \(command)")
switch command {
    case "list":
        list (dayOnDate: Date())
        break
    case "insert":
        insertIssue (arguments: arguments)
        break
    case "scrum","lunch","meeting","nap","learning","coderev":
        insert (taskType: command, arguments: arguments)
        break
    default:
        printHelp()
        break
}

exit(0)

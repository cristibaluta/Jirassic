//
//  jirassic
//
//  Created by Baluta Cristian on 06/01/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

var shouldKeepRunning = true
let theRL = RunLoop.current
let appVersion = "17.02.28"
//while shouldKeepRunning && theRL.run(mode: .defaultRunLoopMode, before: .distantFuture) {}

enum ArgType {
    case taskNr
    case notes
}

enum Command: String {
    case list = "list"
    case reports = "reports"
    case insert = "insert"
    case scrum = "scrum"
    case lunch = "lunch"
    case meeting = "meeting"
    case nap = "nap"
    case learning = "learning"
    case coderev = "coderev"
    case version = "version"
}

func printHelp() {
    print("jirassic \(appVersion) - (c)2017 Imagin soft")
    print("Usage:")
    print("     list [yyyy.mm.dd] If date is missing list tasks from today")
    print("     reports [yyyy.mm.dd] [-no-round] If date is missing list reports from today")
    print("     insert -nr <task number> -notes <notes> -duration <mm>")
    print("     [scrum,lunch,meeting,nap,learning,coderev] <duration>  Duration in minutes")
    print("")
}

let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
let libraryDirectory = urls.first!
let jirassicSandboxedAppSupportDir = libraryDirectory.appendingPathComponent("Containers/com.ralcr.Jirassic.osx/Data/Library/Application Support/Jirassic")
print(urls)
print(jirassicSandboxedAppSupportDir)
// /Users/Cristian/Library/Containers/com.ralcr.Jirassic.osx/Data/Library/Application%20Support/Jirassic/
// /Users/Cristian/Library/Application%20Support/Jirassic/
let localRepository: Repository! = RealmRepository(documentsDirectory: jirassicSandboxedAppSupportDir.path)
var remoteRepository: Repository?


//let settings = localRepository!.settings()
//print(currentTasks)


// Insert the task
var arguments = ProcessInfo.processInfo.arguments
arguments.append("list")
//arguments.append("2017.03.01")
print(arguments)
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
    
    print("")
    let reader = ReadTasksInteractor(repository: localRepository)
    let tasks = reader.tasksInDay(date)
    if tasks.count > 0 {
        for task in tasks {
            print(task.endDate.HHmm() + " " + task.notes!)
        }
    } else {
        print("No tasks!")
    }
    print("")
}

func reports (dayOnDate date: Date) {
    
    print("")
    let reader = ReadTasksInteractor(repository: localRepository)
    let tasks = reader.tasksInDay(date)
    if tasks.count > 0 {
        for task in tasks {
            print(task.endDate.HHmm() + " " + task.notes!)
        }
    } else {
        print("No tasks!")
    }
    print("")
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

func insert (taskType: Command, arguments: [String]) {
    
    guard dayStarted() else {
        return
    }
    var task: Task?
    
    switch taskType {
        case .scrum: task = Task(subtype: .scrumEnd)
            break
        case .lunch: task = Task(subtype: .lunchEnd)
            break
        case .meeting: task = Task(subtype: .meetingEnd)
            break
        case .nap: task = Task(subtype: .napEnd)
            break
        case .learning: task = Task(subtype: .learningEnd)
            break
        case .coderev: task = Task(subtype: .coderevEnd)
            break
        default:
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

let commandStr = arguments.remove(at: 0)
if let command = Command(rawValue: commandStr) {
    switch command {
        case .list:
            var date = Date()
            if arguments.count > 0 {
                let arg = arguments.remove(at: 0)
                date = Date(YYYYMMddString: arg)
            }
            list (dayOnDate: date)
            break
        case .reports:
            reports (dayOnDate: Date())
            break
        case .insert:
            insertIssue (arguments: arguments)
            break
        case .scrum, .lunch, .meeting, .nap, .learning, .coderev:
            insert (taskType: command, arguments: arguments)
            break
        case .version:
            print(appVersion)
    }
} else {
    print("\nUnsupported command.\n")
    printHelp()
}

exit(0)

//
//  jirassic
//
//  Created by Baluta Cristian on 06/01/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

var shouldKeepRunning = true
let theRL = RunLoop.current
let appVersion = "20.01.08"
//while shouldKeepRunning && theRL.run(mode: .defaultRunLoopMode, before: .distantFuture) {}

enum ArgType {
    case taskNr
    case notes
}

enum Command: String {
    case list = "list"
    case reports = "reports"
    case start = "start"
    case insert = "insert"
    case scrum = "scrum"
    case lunch = "lunch"
    case meeting = "meeting"
    case waste = "waste"
    case learning = "learning"
    case coderev = "coderev"
    case version = "version"
}

func printHelp() {
    print("")
    print("jirassic \(appVersion) - (c)2020 Imagin soft")
    print("")
    print("Usage:")
    print("     list [yyyy.mm.dd]  If date is missing list tasks from today")
    print("     reports [yyyy.mm.dd|yyyy.mm] [hours per day]  If date is missing, list reports from today")
    print("     start")
    print("     insert -nr <task number> -notes <notes> -duration <mm>")
    print("     scrum|lunch|meeting|waste|learning|coderev <duration>  Duration in minutes")
    print("")
}

let urls = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
let libraryDirectory = urls.first!
let jirassicSandboxedAppSupportDir = libraryDirectory.appendingPathComponent("Containers/com.jirassic.macos/Data/Library/Application Support/Jirassic")
//print(urls)
//print(jirassicSandboxedAppSupportDir)
// /Users/Cristian/Library/Containers/com.ralcr.Jirassic.osx/Data/Library/Application%20Support/Jirassic/
// /Users/Cristian/Library/Application%20Support/Jirassic/
let localRepository: Repository! = SqliteRepository(documentsDirectory: jirassicSandboxedAppSupportDir)
var remoteRepository: Repository?
let reader = ReadTasksInteractor(repository: localRepository, remoteRepository: remoteRepository)


//let settings = localRepository!.settings()
//print(currentTasks)


// Insert the task
var arguments = ProcessInfo.processInfo.arguments
//arguments.append("list")
//arguments.append("2018.11.09")
//arguments.append("reports")
//arguments.append("2018.11.09")
//arguments.append("6")
//print(arguments)

arguments.remove(at: 0)// First arg is the filepath and needs to be removed

guard arguments.count > 0 else {
    printHelp()
    exit(0)
}

func dayStarted() -> Bool {
    
    let currentTasks = reader.tasksInDay(Date())
    guard currentTasks.count > 0 else {
        print("Working day was not started yet, start it with 'jirassic start'")
        return false
    }
    return true
}

func list (dayOnDate date: Date) {
    
    print("")
    let tasks = reader.tasksInDay(date)
    if tasks.count > 0 {
        for task in tasks {
            let startTime = task.startDate != nil ? (task.startDate!.HHmm() + " ") : ""
            let notes = task.notes ?? task.taskType.defaultNotes
            print("• " + startTime + task.endDate.HHmm() + " " + notes)
        }
    } else {
        print("No tasks!")
    }
    print("")
}

func reports (forDay date: Date, targetHoursInDay: Double?) {
    
    print("")
    let tasks = reader.tasksInDay(date)
    let reportsInteractor = CreateReport()
    let duration: Double? = targetHoursInDay != nil ? targetHoursInDay!.hoursToSec : nil
    let reports = reportsInteractor.reports(fromTasks: tasks, targetHoursInDay: duration)
    if reports.count > 0 {
        let message = reportsInteractor.toString(reports)
        print(message)
        print("")
        let workedLength = StatisticsInteractor().duration(of: reports)
        print("Total duration: \(workedLength.secToHoursAndMin)")
    } else {
        print("No tasks!")
    }
    print("")
}

func reports (forMonth date: Date, targetHoursInDay: Double?) {

    print("")
    print("Reports for the month of \(date.startOfMonth().MMMMdd()) - \(date.endOfMonth().MMMMdd()) \(date.YYYY())")
    print("")
    
    let tasks = reader.tasksInMonth(date)
    let monthReportsInteractor = CreateMonthReport()
    let duration: Double? = targetHoursInDay != nil ? targetHoursInDay!.hoursToSec : nil
    let result = monthReportsInteractor.reports(fromTasks: tasks, targetHoursInDay: duration, roundHours: true)
    if result.byTasks.count > 0 {
        let joined = monthReportsInteractor.joinReports(result.byTasks)
        print(joined.notes)
        print("")
        print("Total duration: \(joined.totalDuration.secToHoursAndMin)")
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
        lastModifiedDate: nil,
        startDate: nil,
        endDate: Date(),
        notes: notes,
        taskNumber: taskNumber,
        taskTitle: nil,
        taskType: taskType,
        objectId: String.generateId()
    )
//    print(task)
    let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: remoteRepository)
    saveInteractor.saveTask(task, allowSyncing: false, completion: {_ in 
        
    })
    
    print("Task saved")
}

func insert (taskType: Command, arguments: [String]) {
    
    guard dayStarted() else {
        return
    }
    var task: Task?
    
    switch taskType {
        case .start: task = Task(endDate: Date(), type: .startDay)
        case .scrum: task = Task(endDate: Date(), type: .scrum)
        case .lunch: task = Task(endDate: Date(), type: .lunch)
        case .meeting: task = Task(endDate: Date(), type: .meeting)
        case .waste: task = Task(endDate: Date(), type: .waste)
        case .learning: task = Task(endDate: Date(), type: .learning)
        case .coderev: task = Task(endDate: Date(), type: .coderev)
        default: return
    }
    
    if let duration = arguments.first {
        if let d = Double(duration) {
            if d > 0 {
                let startDate = task?.endDate.addingTimeInterval(d)
                task?.startDate = startDate
            }
        }
    }
    
//    print(task!)
    let saveInteractor = TaskInteractor(repository: localRepository, remoteRepository: nil)
    saveInteractor.saveTask(task!, allowSyncing: false, completion: { _ in })
    
    print(taskType.rawValue.capitalized + " saved")
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
            var date = Date()
            var duration: Double? = nil
            if arguments.count >= 2 {
                duration = Double(arguments[1])
            }
            if arguments.count > 0 {
                let arg = arguments.remove(at: 0)
                if arg.components(separatedBy: ".").count == 2 {
                    // We have only year and month. Add a day and call the month reports
                    date = Date(YYYYMMddString: "\(arg).01")
                    reports (forMonth: date, targetHoursInDay: duration)
                    break
                } else if arg.components(separatedBy: ".").count == 3 {
                    // We have year, month and day
                    date = Date(YYYYMMddString: arg)
                }
            }
            reports (forDay: date, targetHoursInDay: duration)
            break
        case .start:
            insert (taskType: command, arguments: [])
        case .insert:
            insertIssue (arguments: arguments)
        case .scrum, .lunch, .meeting, .waste, .learning, .coderev:
            insert (taskType: command, arguments: arguments)
        case .version:
            print(appVersion)
    }
} else {
    print("\nUnsupported command.\n")
    printHelp()
}

exit(0)

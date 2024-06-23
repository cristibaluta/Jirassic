//
//  LocalPreferences.swift
//  Jirassic
//
//  Created by Cristian Baluta on 23/04/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation
import RCPreferences

enum LocalPreferences: String, RCPreferencesProtocol {
    
    case launchAtStartup = "launchAtStartup"
    case usePercents = "usePercents"
    case useDuration = "useDuration"
    // Currently installed app version. In case of an update this is the version of the previous app
    case appVersion = "appVersion"
    case wizardSteps = "wizardSteps"
    case settingsActiveTab = "settingsActiveTab"
    case settingsJiraUrl = "settingsJiraUrl"
    case settingsJiraUser = "settingsJiraUser"
    case settingsJiraProjectId = "settingsJiraProjectId"
    case settingsJiraProjectKey = "settingsJiraProjectKey"
    case settingsJiraProjectIssueKey = "settingsJiraProjectIssueKey"
    case settingsHookupCmdName = "settingsHookupCmdName"
    case settingsHookupAppName = "settingsHookupAppName"
    case settingsSelectedCalendars = "settingsSelectedCalendars"
    case enableGit = "enableGit"
    case enableJit = "enableJit"
    case enableRoundingDay = "enableRoundingDay"
    case enableHookup = "enableHookup"
    case enableCocoaHookup = "enableCocoaHookup"
    case enableHookupCredentials = "enableHookupCredentials"
    case enableCalendar = "enableCalendar"
    case copyWorklogsAsHtml = "copyWorklogsAsHtml"
    
    func defaultValue() -> Any {
        switch self {
        case .launchAtStartup:          return false
        case .usePercents:              return true
        case .useDuration:              return false
        case .appVersion:               return ""
        case .wizardSteps:              return []
        case .settingsActiveTab:        return SettingsTab.tracking.rawValue
        case .settingsJiraUrl:          return ""
        case .settingsJiraUser:         return ""
        case .settingsJiraProjectId:    return ""
        case .settingsJiraProjectKey:   return ""
        case .settingsJiraProjectIssueKey:return ""
        case .settingsHookupCmdName:    return ""
        case .settingsHookupAppName:    return ""
        case .settingsSelectedCalendars:return "Work,Calendar"
        case .enableGit:                return false
        case .enableJit:                return true
        case .enableRoundingDay:        return false
        case .enableHookup:             return false
        case .enableCocoaHookup:        return false
        case .enableHookupCredentials:  return false
        case .enableCalendar:           return false
        case .copyWorklogsAsHtml:       return false
        }
    }
}

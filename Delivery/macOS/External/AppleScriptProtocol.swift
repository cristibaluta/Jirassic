//
//  AppleScriptProtocol.swift
//  Jirassic
//
//  Created by Cristian Baluta on 24/03/2018.
//  Copyright © 2018 Imagin soft. All rights reserved.
//

import Foundation

protocol AppleScriptProtocol {
    
    var scriptsDirectory: URL? {get}
    
    func run (command: String, completion: @escaping (String?) -> Void)
    
    func getScriptVersion (script: String, completion: @escaping (String) -> Void)
    
    func getJitInfo (completion: @escaping ([String: String]) -> Void)
    
    func getJirassicVersion (completion: @escaping (String) -> Void)
    
    func getBrowserInfo (browserId: String, browserName: String, completion: @escaping (String, String) -> Void)
    
    func downloadFile (from: String, to: String, completion: @escaping (Bool) -> Void)
    
    func removeFile (from: String, completion: @escaping (Bool) -> Void)
    
}

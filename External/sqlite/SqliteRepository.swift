//
//  CoreDataRepository.swift
//  Jirassic
//
//  Created by Cristian Baluta on 15/04/16.
//  Copyright © 2016 Cristian Baluta. All rights reserved.
//

import Foundation

class SqliteRepository {
    
    fileprivate let appName = "Jirassic"
    fileprivate let databaseName = "Jirassic"
    fileprivate var db: SQLiteDB!
    
    init() {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let baseUrl = urls.last!
        let url = baseUrl.appendingPathComponent(appName)
        open(atUrl: url)
    }
    
    required init (documentsDirectory: URL) {
        open(atUrl: documentsDirectory)
    }
    
    fileprivate func open (atUrl url: URL) {
        
        if !FileManager.default.fileExists(atPath: url.path) {
            try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
        }
        let dbUrl = url.appendingPathComponent("\(databaseName).sqlite")
        RCLog(dbUrl)
        
        db = SQLiteDB(url: dbUrl)
        _ = SQLiteSchema(db: db)
    }
    
    internal func queryWithPredicate<T: SQLTable> (_ predicate: String?, sortingKeyPath: String?) -> [T] {
        
        var results = [T]()
        
        let resultsObjs = T.rows(filter: predicate ?? "", order: sortingKeyPath != nil ? "\(sortingKeyPath!) ASC" : "") as! [T]
//        RCLog(resultsObjs)
        for result in resultsObjs {
            results.append(result)
        }
        
        return results
    }
}

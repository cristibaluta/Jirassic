//
//  SQLTable.swift
//  SQLiteDB-iOS
//
//  Created by Fahim Farook on 6/11/15.
//  Copyright © 2015 RookSoft Pte. Ltd. All rights reserved.
//

import Foundation

@objcMembers
class SQLTable: NSObject {
    
    /// Internal reference to the SQLite table name as determined based on the name of the `SQLTable` sub-class name. The sub-class name should be in the singular - for example, Task for a tasks table.
    internal var table = ""
    /// Internal dictionary to keep track of whether a specific table was verfied to be in existence in the database. This dictionary is used to automatically create the table if it does not exist in the DB.
    private static var verified = [String: Bool]()
    private var db = SQLiteDB.shared
	
    /// Static variable indicating the table name - used in class methods since the instance variable `table` is not accessible in class methods.
    private static var table: String {
		let cls = "\(classForCoder())".lowercased()
		let ndx = cls.index(before: cls.endIndex)
        let tnm = cls.hasSuffix("y") ? cls[..<ndx] + "ies" : (cls.hasSuffix("s") ? cls + "es" : cls + "s")
		return tnm
	}
	
	required override init() {
		super.init()
        self.table = type(of: self).table
        let verified = SQLTable.verified[table]
        if verified == nil || !verified! {
            // Verify that the table exists in DB
            var sql = "SELECT name FROM sqlite_master WHERE type='table' AND lower(name)='\(table)'"
            let cnt = db?.query(sql:sql).count
            if cnt == 1 {
                // Table exists, proceed
                SQLTable.verified[table] = true
            } else if cnt == 0 {
                // Table does not exist, create it
                sql = "CREATE TABLE IF NOT EXISTS \(table) ("
                // Columns
                let cols = values()
                sql += getColumnSQL(columns:cols)
                // Close query
                sql += ")"
                let rc = db?.execute(sql:sql)
                if rc == 0 {
                    assert(false, "Error creating table - \(table) with SQL: \(sql)")
                }
                SQLTable.verified[table] = true
            } else {
                assert(false, "Got more than one table in DB with same name! Count: \(String(describing: cnt)) for \(table)")
            }
        }
	}
	
	// MARK:- Table property management
	func primaryKey() -> String {
		return "id"
	}
	
	func ignoredKeys() -> [String] {
		return []
	}
	
	// MARK:- Class Methods
	class func rows (filter: String = "", order: String = "", limit: Int = 0) -> [SQLTable] {
		var sql = "SELECT * FROM \(table)"
		if !filter.isEmpty {
			sql += " WHERE \(filter)"
		}
		if !order.isEmpty {
			sql += " ORDER BY \(order)"
		}
		if limit > 0 {
			sql += " LIMIT 0, \(limit)"
		}
		return self.rowsFor(sql: sql)
	}
    
	class func rowsFor (sql: String = "") -> [SQLTable] {
		var res = [SQLTable]()
		let tmp = self.init()
		let data = tmp.values()
		let db = SQLiteDB.shared!
		let fsql = sql.isEmpty ? "SELECT * FROM \(table)" : sql
		let arr = db.query(sql: fsql)
		for row in arr {
			let t = self.init()
			for (key, _) in data {
				if let val = row[key] {
					t.setValue(val, forKey: key)
				}
			}
			res.append(t)
		}
		return res
	}
	
	class func rowBy (id: Any) -> SQLTable? {
		let row = self.init()
		let data = row.values()
		let db = SQLiteDB.shared!
		var val = "\(id)"
		if id is String {
			val = "'\(id)'"
		}
		let sql = "SELECT * FROM \(table) WHERE \(row.primaryKey())=\(val)"
		let arr = db.query(sql: sql)
		if arr.count == 0 {
			return nil
		}
		for (key, _) in data {
			if let val = arr[0][key] {
				row.setValue(val, forKey: key)
			}
		}
		return row
	}
	
	class func count (filter: String = "") -> Int {
		let db = SQLiteDB.shared!
		var sql = "SELECT COUNT(*) AS count FROM \(table)"
		if !filter.isEmpty {
			sql += " WHERE \(filter)"
		}
		let arr = db.query(sql:sql)
		if arr.count == 0 {
			return 0
		}
		if let val = arr[0]["count"] as? Int {
			return val
		}
		return 0
	}
	
	class func row (number: Int, filter: String = "", order: String = "") -> SQLTable? {
		let row = self.init()
		let data = row.values()
		let db = SQLiteDB.shared!
		var sql = "SELECT * FROM \(table)"
		if !filter.isEmpty {
			sql += " WHERE \(filter)"
		}
		if !order.isEmpty {
			sql += " ORDER BY \(order)"
		}
		// Limit to specified row
		sql += " LIMIT 1 OFFSET \(number-1)"
		let arr = db.query(sql:sql)
		if arr.count == 0 {
			return nil
		}
		for (key, _) in data {
			if let val = arr[0][key] {
				row.setValue(val, forKey:key)
			}
		}
		return row
	}
	
	class func remove (filter: String = "") -> Bool {
		let db = SQLiteDB.shared!
		let sql: String
		if filter.isEmpty {
			// Delete all records
			sql = "DELETE FROM \(table)"
		} else {
			// Use filter to delete
			sql = "DELETE FROM \(table) WHERE \(filter)"
		}
		let rc = db.execute(sql: sql)
		return (rc != 0)
	}
	
	class func zap() {
		let db = SQLiteDB.shared!
		let sql = "DELETE FROM \(table)"
		_ = db.execute(sql:sql)
	}
	
	// MARK:- Public Methods
	func save() -> Int {
		let db = SQLiteDB.shared!
		let key = primaryKey()
		let data = values()
		var insert = true
		if let rid = data[key] {
			var val = "\(rid)"
			if rid is String {
				val = "'\(rid)'"
			}
			let sql = "SELECT COUNT(*) AS count FROM \(table) WHERE \(primaryKey())=\(val)"
			let arr = db.query(sql: sql)
			if arr.count == 1 {
				if let cnt = arr[0]["count"] as? Int {
					insert = (cnt == 0)
				}
			}
		}
		// Insert or update
		let (sql, params) = getSQL(data: data, forInsert: insert)
		let rc = db.execute(sql: sql, parameters: params)
		if rc == 0 {
            if SQLiteDB.sql_logs_enabled { print("Error saving record!") }
			return 0
		}
		// Update primary key
		let pid = data[key]
		if insert {
			if pid is Int64 {
				setValue(rc, forKey: key)
			} else if pid is Int {
				setValue(Int(rc), forKey: key)
			}
		}
		return rc
	}
	
	func delete() -> Bool {
		let db = SQLiteDB.shared!
		let key = primaryKey()
		let data = values()
		if let rid = data[key] {
            let v: String
            if let s = rid as? String {
                v = "'\(s)'"
            } else {
                v = "\(rid)"
            }
			let sql = "DELETE FROM \(table) WHERE \(primaryKey())=\(v)"
			let rc = db.execute(sql: sql)
			return (rc != 0)
		}
		return false
	}
	
	func refresh() {
		let db = SQLiteDB.shared!
		let key = primaryKey()
		let data = values()
		if let rid = data[key] {
			let sql = "SELECT * FROM \(table) WHERE \(primaryKey())=\(rid)"
			let arr = db.query(sql:sql)
			for (key, _) in data {
				if let val = arr[0][key] {
					setValue(val, forKey: key)
				}
			}
		}
	}
	
	// MARK:- Private Methods
//	private func properties() -> [String] {
//		var res = [String]()
//		for c in Mirror(reflecting:self).children {
//			if let name = c.label{
//				res.append(name)
//			}
//		}
//		return res
//	}
	
	internal func values() -> [String: Any] {
		var res = [String: Any]()
		let obj = Mirror(reflecting: self)
		for (_, attr) in obj.children.enumerated() {
			if let name = attr.label {
				// Ignore special properties and lazy vars
				if ignoredKeys().contains(name) || name.hasSuffix(".storage") {
					continue
				}
                res[name] = attr.value
			}
		}
		return res
	}
    
    /// Returns a valid SQL statement and matching list of bound parameters needed to insert a new row into the database or to update an existing row of data.
    ///
    /// - Parameters:
    ///   - data: A dictionary of property names and their corresponding values that need to be persisted to the underlying table.
    ///   - forInsert: A boolean value indicating whether this is an insert or update action.
    /// - Returns: A tuple containing a valid SQL command to persist data to the underlying table and the bound parameters for the SQL command, if any.
	private func getSQL (data: [String: Any], forInsert: Bool = true) -> (String, [Any]?) {
		var sql = ""
		var params: [Any]? = nil
		if forInsert {
			// INSERT INTO tasks(task, categoryID) VALUES ('\(txtTask.text)', 1)
			sql = "INSERT INTO \(table) ("
		} else {
			// UPDATE tasks SET task = ? WHERE categoryID = ?
			sql = "UPDATE \(table) SET "
		}
		let pkey = primaryKey()
		var wsql = ""
		var rid: Any?
		var first = true
		for (key, val) in data {
			// Primary key handling
			if pkey == key {
				if forInsert {
					if val is Int && (val as! Int) == -1 {
						// Do not add this since this is (could be?) an auto-increment value
						continue
					}
				} else {
					// Update - set up WHERE clause
					wsql += " WHERE " + key + " = ?"
					rid = val
					continue
				}
			}
			// Set up parameter array - if we get here, then there are parameters
			if first && params == nil {
				params = [AnyObject]()
			}
			if forInsert {
				sql += first ? "\(key)" : ", \(key)"
				wsql += first ? " VALUES (?" : ", ?"
				params!.append(val)
			} else {
				sql += first ? "\(key) = ?" : ", \(key) = ?"
				params!.append(val)
			}
			first = false
		}
		// Finalize SQL
		if forInsert {
			sql += ")" + wsql + ")"
		} else if params != nil && !wsql.isEmpty {
			sql += wsql
			params!.append(rid!)
		}
        if SQLiteDB.sql_logs_enabled { print("Final SQL: \(sql) with parameters: \(String(describing: params))") }
		return (sql, params)
	}
    
    /// Returns a valid SQL fragment for creating the columns, with the correct data type, for the underlying table.
    ///
    /// - Parameter columns: A dictionary of property names and their corresponding values for the `SQLTable` sub-class
    /// - Returns: A string containing an SQL fragment for delcaring the columns for the underlying table with the correct data type
    private func getColumnSQL (columns: [String: Any]) -> String {
        var sql = ""
        for key in columns.keys {
            let val = columns[key]!
            var col = "'\(key)' "
            if val is Int {
                // Integers
                col += "INTEGER"
                if key == primaryKey() {
                    col += " PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE"
                }
            } else {
                // Other values
                if val is Float || val is Double {
                    col += "REAL"
                } else if val is Bool {
                    col += "BOOLEAN"
                } else if val is Date {
                    col += "DATE"
                } else if val is NSData {
                    col += "BLOB"
                } else {
                    // Default to text
                    col += "TEXT"
                }
                if key == primaryKey() {
                    col += " PRIMARY KEY NOT NULL UNIQUE"
                }
            }
            if sql.isEmpty {
                sql = col
            } else {
                sql += ", " + col
            }
        }
        return sql
    }
}

//
//  main.swift
//  fda
//
//  Created by Elangovan Ayyasamy on 30/07/21.
//

import Foundation

func Help()
{
    print("fda by @krishpranav")
    print("Usage:")
    print("-h | -help       Print Help Menu")
    print("-p | -path       /path/to/tcc.db")
    print("-t | -table      Outputs result as a text table")
}

if CommandLine.arguments.count == 1 {
    Help()
    exit(0)
}
else {
    for argument in CommandLine.arguments {
        if (argument.contains("-h") || argument.contains("-help")) {
            Help()
            exit(0)
        }
        else if (argument.contains("-p") || argument.contains("-path")) {
            var path = CommandLine.arguments[2]
            if path.contains("~") {
                path = NSString(string: path).expandingTildeInPath
            }
            let fileURL = URL(fileURLWithPath: path)
            var db: OpaquePointer?
            guard sqlite3_open(fileURL.path, &db) == SQLITE_OK else {
                print("Error: Could not open \(fileURL.path)")
                sqlite3_close(db)
                db = nil
                exit(0)
            }
            
            if CommandLine.arguments.contains("-t") || CommandLine.arguments.contains("-table") {
                queryAccess(db: db!, createTable: true)
                let tableString = table.render()
                print(tableString)
            }
            else {
                querySchema(db: db!)
                print("")
                queryAccess(db: db!, createTable: false)
            }
            
        }
    }
}

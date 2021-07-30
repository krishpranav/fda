//
//  main.swift
//  fda
//
//  Created by Elangovan Ayyasamy on 30/07/21.
//

import Foundation
import SQLite3

let service_Column = TextTableColumn(header: "service")
let client_Column = TextTableColumn(header: "client")
let client_type_Column = TextTableColumn(header: "client_type")
let auth_value_Column = TextTableColumn(header: "auth_value")
let auth_reason_Column = TextTableColumn(header: "auth_reason")
let auth_version_Column = TextTableColumn(header: "auth_version")
let csreq_Column = TextTableColumn(header: "csreq")
let policy_id_Column = TextTableColumn(header: "policy_id")
let indirect_object_identifier_type_Column = TextTableColumn(header: "indirect_object_identifier_type")
let indirect_object_identifier_Column = TextTableColumn(header: "indirect_object_identifier")
let indirect_object_code_identity_Column = TextTableColumn(header: "indirect_object_code_identity")
let flags_Column = TextTableColumn(header: "flags")
let last_modified_Column = TextTableColumn(header: "last_modified")

func toBase64(data: Data) -> String {
    return data.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
}

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

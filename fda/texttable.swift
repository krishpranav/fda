//
//  texttable.swift
//  fda
//
//  Created by Elangovan Ayyasamy on 30/07/21.
//

import Foundation

typealias Regex = NSRegularExpression

private let strippingRegex = try! Regex(pattern: strippingRegex, options: [])

private extension String {
    func stripped() -> String {
#if os(Linux)
        let length = NSString(string: self).length
#else
        let length = (self as NSString).length
#endif
        return strippingRegex.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: length),
            withTemplate: ""
        )
    }
}

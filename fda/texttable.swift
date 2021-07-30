//
//  texttable.swift
//  fda
//
//  Created by Elangovan Ayyasamy on 30/07/21.
//

// imports
import Foundation

typealias Regex = NSRegularExpression

private let strippingPattern = "\\\u{001B}\\[([0-9][0-9]?m|[0-9](;[0-9]*)*m)"

private let strippingRegex = try! Regex(pattern: strippingPattern, options: [])

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

public struct TextTable {

    private var columns: [TextTableColumn]

    public var columnFence = "|"

    public var rowFence = "-"

    public var cornerFence = "+"

    public var header: String?
    public init(columns: [TextTableColumn], header: String? = nil) {
        self.columns = columns
        self.header = header
    }

    public init<T: TextTableRepresentable>(objects: [T], header: String? = nil) {
        self.header = header ?? T.tableHeader
        columns = T.columnHeaders.map { TextTableColumn(header: $0) }
        objects.forEach { addRow(values: $0.tableValues) }
    }


    public mutating func addRow(values: [CustomStringConvertible]) {
        let values = values.count >= columns.count ? values :
            values + [CustomStringConvertible](repeating: "", count: columns.count - values.count)
        columns = zip(columns, values).map {
            (column, value) in
            var column = column
            column.values.append(value.description)
            return column
        }
    }

    public mutating func addRows(values: [[CustomStringConvertible]]) {
        for index in 0..<columns.count {
            let columnValues: [String] = values.map { row in index < row.count ? row[index].description : "" }
            columns[index].values.append(contentsOf: columnValues)
        }
    }

    public mutating func clearRows() {
        for index in 0..<columns.count {
            columns[index].values = []
        }
    }

    public func render() -> String {
        let separator = fence(strings: columns.map({ column in
            return repeatElement(rowFence, count: column.width() + 2).joined()
        }), separator: cornerFence)

        let top = renderTableHeader() ?? separator

        let columnHeaders = fence(
            strings: columns.map({ " \($0.header.withPadding(count: $0.width())) " }),
            separator: columnFence
        )

        let values = columns.isEmpty ? "" : (0..<columns.first!.values.count).map({ rowIndex in
            fence(strings: columns.map({ " \($0.values[rowIndex].withPadding(count: $0.width())) " }), separator: columnFence)
        }).paragraph()

        return [top, columnHeaders, separator, values, separator].paragraph()
    }

    /**
     Render the table's header to a `String`.

     - returns: The `String` representation of the table header. `nil` if `header` is `nil`.
     */
    private func renderTableHeader() -> String? {
        guard let header = header else {
            return nil
        }

        let calculatewidth: (Int, TextTableColumn) -> Int = { $0 + $1.width() + 2 }
        let separator = cornerFence +
            repeatElement(rowFence, count: columns.reduce(0, calculatewidth) + columns.count - 1).joined() +
        cornerFence
#if swift(>=3.2)
        let separatorCount = separator.count
#else
        let separatorCount = separator.characters.count
#endif
        let title = fence(strings: [" \(header.withPadding(count: separatorCount - 4)) "], separator: columnFence)

        return [separator, title, separator].paragraph()
    }
}

public struct TextTableColumn {

    public var header: String {
        didSet {
            computeWidth()
        }
    }

    fileprivate var values: [String] = [] {
        didSet {
            computeWidth()
        }
    }

    public init(header: String) {
        self.header = header
        computeWidth()
    }

    public func width() -> Int {
        return precomputedWidth
    }

    private var precomputedWidth: Int = 0

    private mutating func computeWidth() {
        let valueLengths = [header.strippedLength()] + values.map { $0.strippedLength() }
        if let max = valueLengths.max() {
            precomputedWidth = max
        }
    }

}


public protocol TextTableRepresentable {

    static var tableHeader: String? { get }

    static var columnHeaders: [String] { get }

    var tableValues: [CustomStringConvertible] { get }
}

public extension TextTableRepresentable {

    static var tableHeader: String? {
        return nil
    }
}

private func fence(strings: [String], separator: String) -> String {
    return separator + strings.joined(separator: separator) + separator
}

public extension Array where Element: TextTableRepresentable {

    func renderTextTable() -> String {
        let table = TextTable(objects: self)
        return table.render()
    }
}

private extension String {
    func withPadding(count: Int) -> String {
        let length = self.strippedLength()

        if length < count {
            return self +
                repeatElement(" ", count: count - length).joined()
        }
        return self
    }

    func strippedLength() -> Int {
#if swift(>=3.2)
        return stripped().count
#else
        return stripped().characters.count
#endif
    }
}

private extension Array where Element: CustomStringConvertible {
    func paragraph() -> String {
        return self.map({ $0.description }).joined(separator: "\n")
    }
}

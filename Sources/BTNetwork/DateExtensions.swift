//
//  DateExtensions.swift
//  BTNetwork
//
//  Created by Rodrigo Baroni on 15/09/21.
//

import Foundation
extension JSONDecoder {

    /// Assign multiple DateFormatter to dateDecodingStrategy
    ///
    /// Usage :
    ///
    ///      decoder.dateDecodingStrategyFormatters = [ DateFormatter.standard, DateFormatter.yearMonthDay ]
    ///
    /// The decoder will now be able to decode two DateFormat, the 'standard' one and the 'yearMonthDay'
    ///
    /// Throws a 'DecodingError.dataCorruptedError' if an unsupported date format is found while parsing the document
    var dateDecodingStrategyFormatters: [DateFormatter]? {
        @available(*, unavailable, message: "This variable is meant to be set only")
        get { return nil }
        set {
            guard let formatters = newValue else { return }
            self.dateDecodingStrategy = .custom { decoder in

                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                for formatter in formatters {
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }

                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
            }
        }
    }
}

extension DateFormatter {
    static let standardT: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        return dateFormatter
    }()

    static let standard: DateFormatter = {
        var dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return dateFormatter
    }()
}

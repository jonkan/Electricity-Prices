//
//  DateIntervalFormatter.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-13.
//

import Foundation

struct DateIntervalFormatter {
    static func formatted(
        from start: Date,
        to end: Date,
        style: FormattingStyle
    ) -> String {
        switch style {
        case .normal:
            return "\(DateFormatter.normal.string(from: start)) - \(DateFormatter.normal.string(from: end))"
        case .short:
            return "\(DateFormatter.short.string(from: start))-\(DateFormatter.short.string(from: end))"
        }
    }
}

private extension DateFormatter {
    static let normal: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df
    }()

    static let short: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "H"
        return df
    }()
}

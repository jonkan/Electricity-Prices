//
//  DateIntervalFormatter.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-13.
//

import Foundation
import SwiftDate

struct DateIntervalFormatter {
    static func formatted(
        from start: DateInRegion,
        to end: DateInRegion,
        style: FormattingStyle
    ) -> String {
        switch style {
        case .normal:
            return "\(start.toFormat("HH:mm")) - \(end.toFormat("HH:mm"))"
        case .short:
            return "\(start.toFormat("H"))-\(end.toFormat("H"))"
        }
    }
}

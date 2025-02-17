//
//  DateFormatter+Helpers.swift
//  Core
//
//  Created by Jonas Värbrand on 2024-11-23.
//

import Foundation
import SwiftUI

extension DateFormatter {
    static func twoDigitHourFormat(locale: Locale = .current) -> DateFormatter {
        let df = DateFormatter()
        df.locale = locale
        df.dateFormat = locale.is24Hour ? "HH" : "hh"
        return df
    }
}

#Preview("Two digit hour date formats") {
    let date = Date(timeIntervalSince1970: 3600*19)
    Grid {
        ForEach(Region.allCases) { region in
            let locale = Locale(identifier: region.id)
            GridRow {
                Text(region.name)
                Text(date, format: .dateTime.hour(.twoDigits(amPM: .omitted)))
                Text(DateFormatter.twoDigitHourFormat(locale: locale).string(from: date))
            }
            .environment(\.locale, locale)
            .gridColumnAlignment(.leading)
        }
    }
    .font(.caption)
}

//
//  Calendar+Helpers.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-29.
//

import Foundation

public extension Calendar {

    func endOfDay(for date: Date) -> Date {
        let startOfDay = self.startOfDay(for: date)
        return self.date(byAdding: .hour, value: 24, to: startOfDay)!
    }

    func startOfHour(for date: Date) -> Date {
        let currentHour = component(.hour, from: date)
        let startOfDay = startOfDay(for: date)
        return self.date(bySettingHour: currentHour, minute: 0, second: 0, of: startOfDay)!
    }

}

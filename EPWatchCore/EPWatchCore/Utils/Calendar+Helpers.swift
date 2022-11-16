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

}

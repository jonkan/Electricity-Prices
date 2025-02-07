//
//  Date+Component.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-11-15.
//

import Foundation

public extension Date {

    static func nowTomorrow(in calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: 1, to: .now)!
    }

    func component(_ component: Calendar.Component, in calendar: Calendar) -> Int {
        return calendar.component(component, from: self)
    }

    func atCET(hour: Int, in calendar: Calendar = .current) -> Date {
        var calendar = calendar
        calendar.timeZone = TimeZone(identifier: "CET")!
        var components = calendar.dateComponents([.year, .month, .day], from: self)
        components.hour = hour
        return calendar.date(from: components)!
    }

}

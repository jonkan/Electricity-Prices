//
//  Date+Component.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-11-15.
//

import Foundation

public extension Date {
    func component(_ component: Calendar.Component, in calendar: Calendar) -> Int {
        return calendar.component(component, from: self)
    }
}

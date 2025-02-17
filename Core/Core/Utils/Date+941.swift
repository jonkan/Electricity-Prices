//
//  File.swift
//  
//
//  Created by Jonas Bromö on 2024-05-08.
//

import Foundation

public extension Date {
    static var nine41: Date {
        Calendar.current.date(bySettingHour: 9, minute: 41, second: 0, of: .now)!
    }
}

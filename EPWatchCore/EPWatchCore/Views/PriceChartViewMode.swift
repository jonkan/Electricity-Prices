//
//  PriceChartViewMode.swift
//  
//
//  Created by Jonas Bromö on 2024-03-26.
//

import Foundation

public enum PriceChartViewMode: String, Codable, CaseIterable, Identifiable, Equatable {
    case today
    case todayAndComingNight
    case todayAndTomorrow

    public var id: String {
        return rawValue
    }

    public var title: String {
        switch self {
        case .today: return String(localized: "Today", bundle: .module)
        case .todayAndComingNight: return String(localized: "Today and Coming Night", bundle: .module)
        case .todayAndTomorrow: return String(localized: "Today and Tomorrow", bundle: .module)
        }
    }
}

//
//  PriceChartStyle.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-11-15.
//

import Foundation

public enum PriceChartStyle: String, Codable, CaseIterable, Identifiable, Equatable {
    case lineInterpolated
    case line
    case bar

    public var id: String {
        return rawValue
    }

    public var title: String {
        switch self {
        case .lineInterpolated: return "Line (interpolated)"
        case .line: return "Line"
        case .bar: return "Bar"
        }
    }
}

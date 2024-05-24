//
//  PriceChartStyle.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-11-15.
//

import SwiftUI

public enum PriceChartStyle: String, Codable, CaseIterable, Identifiable, Equatable {
    case bar
    case line
    case lineInterpolated

    public var id: String {
        return rawValue
    }

    public var title: String {
        switch self {
        case .lineInterpolated:
            return String(
                localized: "Line (interpolated)",
                bundle: .module,
                comment: "Chart type"
            )
        case .line:
            return String(
                localized: "Line",
                bundle: .module,
                comment: "Chart type"
            )
        case .bar:
            return String(
                localized: "Bar",
                bundle: .module,
                comment: "Chart type"
            )
        }
    }
}

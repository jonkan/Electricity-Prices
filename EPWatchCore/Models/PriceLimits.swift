//
//  PriceLimits.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-15.
//

import Foundation
import SwiftUI

public struct PriceLimits: Codable {
    var high: Double
    var low: Double

    public init(high: Double, low: Double) {
        self.high = high
        self.low = low
    }

    public static let `default` = PriceLimits(high: 3, low: 1)
}

public extension PriceLimits {
    func stops(using range: ClosedRange<Double>) -> [Gradient.Stop] {
        let span = range.upperBound - range.lowerBound
        let highStop = max(0, high - range.lowerBound) / span
        let lowStop = max(0, low - range.lowerBound) / span
        let fadeSize = 0.1
        return [
            .init(color: .green, location: lowStop - fadeSize),
            .init(color: .orange, location: lowStop + fadeSize),
            .init(color: .orange, location: highStop - fadeSize),
            .init(color: .red, location: highStop + fadeSize),
        ]
    }

    func color(of price: Double) -> Color {
        if price >= high {
            return .red
        } else if price >= low {
            return .orange
        } else {
            return .green
        }
    }
}

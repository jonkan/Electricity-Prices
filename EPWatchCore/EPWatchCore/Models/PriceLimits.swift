//
//  PriceLimits.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-15.
//

import Foundation
import SwiftUI

public struct PriceLimits: Codable, Equatable, Sendable {
    public let currency: Currency
    public var high: Double
    public var low: Double

    public init(_ currency: Currency, high: Double, low: Double) {
        self.currency = currency
        self.high = high
        self.low = low
    }
}

public extension PriceLimits {
    func stops(using range: PriceRange) -> [Gradient.Stop] {
        let rangeSpan = range.max - range.min
        let highStop = max(0, high - range.min) / rangeSpan
        let lowStop = max(0, low - range.min) / rangeSpan
        // Make sure lowStop + fadeSize <= highStop - fadeSize
        let fadeSize = min(0.1, (highStop-lowStop)/2)
        return [
            .init(color: .green, location: lowStop - fadeSize),
            .init(color: .orange, location: lowStop + fadeSize),
            .init(color: .orange, location: highStop - fadeSize),
            .init(color: .red, location: highStop + fadeSize)
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

public extension PriceLimits {
    static let mocked = PriceLimits(.SEK, high: 3, low: 1)
}

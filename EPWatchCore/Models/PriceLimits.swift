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
}

public extension PriceLimits {
    func stops(using range: ClosedRange<Double>?) -> [Gradient.Stop] {
        guard let range = range else {
            return [.init(color: .blue, location: 0)]
        }
        let span = range.upperBound - range.lowerBound
        let highStop = max(0, high - range.lowerBound) / span
        let lowStop = max(0, low - range.lowerBound) / span
        let fadeSize = 0.1
        return [
            .init(color: .red, location: highStop + fadeSize),
            .init(color: .orange, location: highStop - fadeSize),
            .init(color: .orange, location: lowStop + fadeSize),
            .init(color: .green, location: lowStop - fadeSize)
        ]
    }
}

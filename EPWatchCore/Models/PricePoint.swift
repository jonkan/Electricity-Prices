//
//  PricePoint.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation
import SwiftDate

public struct PricePoint: Codable, Equatable {
    public var date: Date // And 1h forward
    public var price: Double
    public var dayPriceRange: ClosedRange<Double>

    public init(date: Date, price: Double, dayPriceRange: ClosedRange<Double>) {
        self.date = date
        self.price = price
        self.dayPriceRange = dayPriceRange
    }

    public func formattedPrice(_ style: FormattingStyle) -> String {
        return PriceFormatter.formatted(price, style: style)
    }

    public func formattedTimeInterval(_ style: FormattingStyle) -> String {
        return DateIntervalFormatter.formatted(
            from: date.convertTo(region: .current),
            to: date.convertTo(region: .current).dateByAdding(1, .hour),
            style: style
        )
    }
}

extension PricePoint {
    public static let mockPrice: PricePoint = Self.mockPrices[10]
    public static let mockPrice2: PricePoint = Self.mockPrices[12]
    public static let mockPrice3: PricePoint = Self.mockPrices[14]
    public static let mockPrices: [PricePoint] = {
        var prices: [PricePoint] = []
        let date = DateInRegion().dateAtStartOf(.day)
        for i in 0..<24 {
            let d = (date + i.hours).date
            prices.append(
                PricePoint(date: d, price: 2.3 + 2 * sin(Double.pi/6*Double(i)), dayPriceRange: 0.3...4.3)
            )
        }
        return prices
    }()
}

public extension Array where Element == PricePoint {
     func price(for date: Date) -> PricePoint? {
        let d = date.in(region: .UTC)
        return first(where: {
            guard Calendar.current.isDate($0.date, inSameDayAs: date) else {
                return false
            }
            let s = $0.date.in(region: .UTC)
            return d.hour == s.hour
        })
    }

    func filterInSameDayAs(_ pricePoint: PricePoint, using calendar: Calendar = .current) -> [PricePoint] {
        filter({ calendar.isDate($0.date, inSameDayAs: pricePoint.date) })
    }

}

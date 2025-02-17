//
//  PricePresentation.swift
//
//
//  Created by Jonas Bromö on 2022-12-08.
//

import Foundation

public protocol FormattablePrice {
    var price: Double { get }
    var currency: Currency { get }
}

public struct PricePresentation: Codable, Equatable, Sendable {

    public var currencyPresentation: CurrencyPresentation
    public var adjustment: PriceAdjustment

    public init(
        currencyPresentation: CurrencyPresentation = .subdivided,
        adjustment: PriceAdjustment = PriceAdjustment(isEnabled: false)
    ) {
        self.currencyPresentation = currencyPresentation
        self.adjustment = adjustment
    }

    public func formattedPrice(
        _ formattablePrice: FormattablePrice,
        style: FormattingStyle
    ) -> String {
        return formattedPrice(formattablePrice.price, in: formattablePrice.currency, style: style)
    }

    public func formattedPrice(
        _ price: Double,
        in currency: Currency,
        style: FormattingStyle
    ) -> String {
        let adjustedPrice = adjustment.adjustedPrice(price)
        return currency.formatted(adjustedPrice, style, currencyPresentation)
    }

    public func adjustedPrice(_ pricePoint: PricePoint) -> Double {
        adjustedPrice(pricePoint.price, in: pricePoint.currency)
    }

    public func adjustedPrice(_ price: Double, in currency: Currency) -> Double {
        let adjustedPrice = adjustment.adjustedPrice(price)
        switch currencyPresentation {
        case .automatic:
            return adjustedPrice
        case .subdivided:
            return adjustedPrice * currency.subdivision.subdivisions
        }
    }

    public func adjustedPriceRange(_ range: PriceRange) -> PriceRange {
        PriceRange(
            max: adjustment.adjustedPrice(range.max),
            min: adjustment.adjustedPrice(range.min),
            mean: adjustment.adjustedPrice(range.mean)
        )
    }

}

public extension PricePresentation {
    static let mocked = PricePresentation()
}

//
//  PricePresentation.swift
//  
//
//  Created by Jonas Bromö on 2022-12-08.
//

import Foundation

public struct PricePresentation: Codable, Equatable {

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
        _ pricePoint: PricePoint,
        style: FormattingStyle
    ) -> String {
        return formattedPrice(pricePoint.price, in: pricePoint.currency, style: style)
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

    public func adjustedPriceRange(_ range: ClosedRange<Double>) -> ClosedRange<Double> {
        let adjustedLowerBound = adjustment.adjustedPrice(range.lowerBound)
        let adjustedUpperBound = adjustment.adjustedPrice(range.upperBound)
        return adjustedLowerBound...adjustedUpperBound
    }

}

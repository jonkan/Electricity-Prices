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

    public func formattedDateTimeInterval(
        from pricePoint: PricePoint,
        style: FormattingStyle
    ) -> String {
        return DateIntervalFormatter.formatted(
            from: pricePoint.date,
            to: Calendar.current.date(byAdding: .hour, value: 1, to: pricePoint.date)!,
            style: style
        )
    }

}

extension PricePoint {
    func adjusted(with pricePresentation: PricePresentation) -> Double {
        let adjustedPrice = pricePresentation.adjustment.adjustedPrice(price)
        switch pricePresentation.currencyPresentation {
        case .automatic:
            return adjustedPrice
        case .subdivided:
            return adjustedPrice * currency.subdivision.subdivisions
        }
    }
}

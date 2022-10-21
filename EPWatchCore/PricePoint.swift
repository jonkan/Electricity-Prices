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

    public init(date: Date, price: Double) {
        self.date = date
        self.price = price
    }

    public enum Style {
        case regular, short

        static private let nfRegular: NumberFormatter = {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.currencyCode = "SEK"
            nf.maximumSignificantDigits = 3
            nf.maximumFractionDigits = 2
            return nf
        }()

        static private let nfShort: NumberFormatter = {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumSignificantDigits = 2
            return nf
        }()

        fileprivate func formattedPrice(price: Double) -> String {
            switch self {
            case .regular:
                return Self.nfRegular.string(from: price as NSNumber) ?? ""
            case .short:
                return Self.nfShort.string(from: price as NSNumber) ?? ""
            }
        }

        fileprivate func formattedTimeInterval(from start: DateInRegion, to end: DateInRegion) -> String {
            switch self {
            case .regular:
                return "\(start.toFormat("HH:mm")) - \(end.toFormat("HH:mm"))"
            case .short:
                return "\(start.toFormat("H"))-\(end.toFormat("H"))"
            }
        }
    }

    public func formattedPrice(_ style: Style) -> String {
        return style.formattedPrice(price: price)
    }

    public func formattedTimeInterval(_ style: Style) -> String {
        return style.formattedTimeInterval(
            from: date.convertTo(region: .current),
            to: date.convertTo(region: .current).dateByAdding(1, .hour)
        )
    }
}

extension Array where Element == PricePoint {
    public func price(for date: Date) -> PricePoint? {
        let d = date.in(region: .UTC)
        return first(where: {
            guard Calendar.current.isDate($0.date, inSameDayAs: date) else {
                return false
            }
            let s = $0.date.in(region: .UTC)
            return d.hour == s.hour
        })
    }
}

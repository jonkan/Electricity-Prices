//
//  PricePoint.swift
//  EPWatch WatchKit Extension
//
//  Created by Jonas Bromö on 2022-09-07.
//

import Foundation
import SwiftDate

struct PricePoint: Codable {
    var price: Double
    var start: Date // And 1h forward

    enum Style {
        case regular, short

        static private let nfRegular: NumberFormatter = {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.maximumSignificantDigits = 3
            nf.maximumFractionDigits = 2
            nf.currencyCode = "SEK"
            return nf
        }()

        static private let nfShort: NumberFormatter = {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.locale = .current
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

        fileprivate func formattedTimeInterval(from start: Date, to end: Date) -> String {
            switch self {
            case .regular:
                return "\(start.toFormat("HH:mm")) - \(end.toFormat("HH:mm"))"
            case .short:
                return "\(start.toFormat("HH"))-\(end.toFormat("HH"))"
            }
        }
    }

    func formattedPrice(_ style: Style) -> String {
        return style.formattedPrice(price: price)
    }

    func formattedTimeInterval(_ style: Style) -> String {
        let end = start.dateByAdding(1, .hour).date
        return style.formattedTimeInterval(from: start, to: end)
    }
}

extension Array where Element == PricePoint {
    func price(for date: Date) -> PricePoint? {
        return reversed().first(where: { $0.start <= date })
    }
}

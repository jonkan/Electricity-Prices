//
//  Currency.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-21.
//

import Foundation

public enum Currency: String, Codable, CaseIterable, Identifiable, Equatable {

    case EUR
    case SEK
    case NOK
    case DKK

    public var code: String {
        return rawValue
    }

    public var id: String {
        return code
    }

    public var name: String {
        switch self {
        case .EUR: return "Euro"
        case .SEK: return "Swedish kronor"
        case .NOK: return "Norwegian kroner"
        case .DKK: return "Danish kroner"
        }
    }

    public var sign: String {
        switch self {
        case .EUR: return "€"
        case .SEK: return "kr"
        case .NOK: return "kr"
        case .DKK: return "kr"
        }
    }

    public var subdivision: CurrencySubdivision {
        switch self {
        case .EUR: return CurrencySubdivision(name: "Cent", sign: "c", subdivisions: 100)
        case .SEK: return CurrencySubdivision(name: "Öre", sign: "öre", subdivisions: 100)
        case .NOK: return CurrencySubdivision(name: "Øre", sign: "øre", subdivisions: 100)
        case .DKK: return CurrencySubdivision(name: "Øre", sign: "øre", subdivisions: 100)
        }
    }

}

extension Currency {

    static private let formatterNormal: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumSignificantDigits = 3
        nf.minimumSignificantDigits = 3
        return nf
    }()

    static private let formatterNormalSmall: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumSignificantDigits = 2
        nf.minimumSignificantDigits = 2
        return nf
    }()

    static private let formatterShort: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumSignificantDigits = 2
        nf.minimumSignificantDigits = 2
        return nf
    }()

    static private let formatterShortSmall: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 1
        nf.minimumFractionDigits = 1
        return nf
    }()

    func formatted(
        _ price: Double,
        _ style: FormattingStyle,
        _ currencyPresentation: CurrencyPresentation
    ) -> String {
        let value: String
        var isSubdivided = currencyPresentation == .subdivided
        let subdividedPrice = price * subdivision.subdivisions
        switch (style, currencyPresentation) {
        case (.normal, .natural):
            if price >= 1 {
                value = Self.formatterNormal.string(from: price) ?? ""
            } else {
                isSubdivided = true
                value = Self.formatterNormalSmall.string(from: subdividedPrice) ?? ""
            }
        case (.normal, .subdivided):
            value = Self.formatterNormalSmall.string(from: subdividedPrice) ?? ""
        case (.short, .natural):
            if price >= 1 {
                value = Self.formatterShort.string(from: price) ?? ""
            } else {
                value = Self.formatterShortSmall.string(from: price) ?? ""
            }
        case (.short, .subdivided):
            value = Self.formatterShortSmall.string(from: subdividedPrice) ?? ""
        }

        let formattedPrice: String
        let showSign = style == .normal
        if showSign {
            switch self {
            case .EUR:
                if isSubdivided {
                    formattedPrice = "\(value)\(subdivision.sign)"
                } else {
                    formattedPrice = "\(sign)\(value)"
                }
            default:
                formattedPrice = "\(value) \(sign)"
            }
        } else {
            formattedPrice = "\(value)"
        }
        return formattedPrice
    }


}

private extension NumberFormatter {
    func string(from value: Double) -> String? {
        string(from: value as NSNumber)
    }
}

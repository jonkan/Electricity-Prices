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
        case .EUR: return String(localized: "Euro", bundle: .module, comment: "Currency name")
        case .SEK: return String(localized: "Swedish krona", bundle: .module, comment: "Currency name")
        case .NOK: return String(localized: "Norwegian krone", bundle: .module, comment: "Currency name")
        case .DKK: return String(localized: "Danish krone", bundle: .module, comment: "Currency name")
        }
    }

    public var shortName: String {
        switch self {
        case .EUR: return String(localized: "Euro", bundle: .module, comment: "Currency name short")
        case .SEK: return String(localized: "Krona", bundle: .module, comment: "Currency name short")
        case .NOK: return String(localized: "Krone", bundle: .module, comment: "Currency name short")
        case .DKK: return String(localized: "Krone", bundle: .module, comment: "Currency name short")
        }
    }

    public var shortNamePlural: String {
        switch self {
        case .EUR: return String(localized: "Euro", bundle: .module, comment: "Currency name short plural")
        case .SEK: return String(localized: "Kronor", bundle: .module, comment: "Currency name short plural")
        case .NOK: return String(localized: "Kroner", bundle: .module, comment: "Currency name short plural")
        case .DKK: return String(localized: "Kroner", bundle: .module, comment: "Currency name short plural")
        }
    }

    public var symbol: String {
        switch self {
        case .EUR: return String(localized: "€", bundle: .module, comment: "Currency symbol")
        case .SEK: return String(localized: "kr", bundle: .module, comment: "Currency symbol")
        case .NOK: return String(localized: "kr", bundle: .module, comment: "Currency symbol")
        case .DKK: return String(localized: "kr", bundle: .module, comment: "Currency symbol")
        }
    }

    public var subdivision: CurrencySubdivision {
        switch self {
        case .EUR:
            return CurrencySubdivision(
                name: String(localized: "Cent", bundle: .module, comment: "Currency subdivision name"),
                symbol: String(localized: "c", bundle: .module, comment: "Currency subdivision symbol"),
                subdivisions: 100
            )
        case .SEK:
            return CurrencySubdivision(
                name: String(localized: "Öre", bundle: .module, comment: "Currency subdivision name"),
                symbol: String(localized: "öre", bundle: .module, comment: "Currency subdivision symbol"),
                subdivisions: 100
            )
        case .NOK: 
            return CurrencySubdivision(
                name: String(localized: "Øre", bundle: .module, comment: "Currency subdivision name"),
                symbol: String(localized:"øre", comment: "Currency subdivision symbol"),
                subdivisions: 100
        )
        case .DKK:
            return CurrencySubdivision(
                name: String(localized: "Øre", bundle: .module, comment: "Currency subdivision name"),
                symbol: String(localized: "øre", bundle: .module, comment: "Currency subdivision symbol"),
                subdivisions: 100
            )
        }
    }

    var suggestedCurrencyPresentation: CurrencyPresentation {
        switch self {
        case .EUR: return .subdivided
        default: return .automatic
        }
    }

}

extension Currency {

    private enum Precision {
        case threeSignificantDigits
        case twoSignificantDigits
        case oneFractionDigit
        case integer
        case integerWithoutGrouping

        func formatted(_ value: Double) -> String {
            Currency.formatters[self]!.string(from: value as NSNumber) ?? ""
        }
    }

    static private var formatters: [Precision: NumberFormatter] = [
        .threeSignificantDigits: {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumSignificantDigits = 3
            nf.minimumSignificantDigits = 3
            return nf
        }(),
        .twoSignificantDigits: {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumSignificantDigits = 2
            nf.minimumSignificantDigits = 2
            return nf
        }(),
        .oneFractionDigit: {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 1
            nf.minimumFractionDigits = 1
            return nf
        }(),
        .integer: {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 0
            nf.minimumFractionDigits = 0
            return nf
        }(),
        .integerWithoutGrouping: {
            let nf = NumberFormatter()
            nf.numberStyle = .decimal
            nf.maximumFractionDigits = 0
            nf.minimumFractionDigits = 0
            nf.usesGroupingSeparator = false
            return nf
        }()
    ]

    public func formatted(
        _ price: Double,
        _ style: FormattingStyle,
        _ currencyPresentation: CurrencyPresentation
    ) -> String {
        let value: String
        var isSubdivided = currencyPresentation == .subdivided
        let subdividedPrice = price * subdivision.subdivisions
        switch (style, currencyPresentation) {
        case (.normal, .automatic):
            if price >= 1 {
                value = Precision.threeSignificantDigits.formatted(price)
            } else {
                isSubdivided = true
                value = Precision.twoSignificantDigits.formatted(subdividedPrice)
            }
        case (.normal, .subdivided):
            if price >= 10 {
                value = Precision.integer.formatted(subdividedPrice)
            } else {
                value = Precision.threeSignificantDigits.formatted(subdividedPrice)
            }
        case (.short, .automatic):
            if price >= 1 {
                value = Precision.twoSignificantDigits.formatted(price)
            } else {
                value = Precision.oneFractionDigit.formatted(price)
            }
        case (.short, .subdivided):
            if subdividedPrice >= 10 {
                value = Precision.integerWithoutGrouping.formatted(subdividedPrice)
            } else {
                value = Precision.oneFractionDigit.formatted(subdividedPrice)
            }
        }

        let formattedPrice: String
        let showSymbol = style == .normal
        if showSymbol {
            switch self {
            case .EUR:
                if isSubdivided {
                    formattedPrice = "\(value)\(subdivision.symbol)"
                } else {
                    formattedPrice = "\(symbol)\(value)"
                }
            default:
                if isSubdivided {
                    formattedPrice = "\(value) \(subdivision.symbol)"
                } else {
                    formattedPrice = "\(value) \(symbol)"
                }
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

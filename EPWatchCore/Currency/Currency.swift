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
        case .SEK: return "Swedish krona"
        case .NOK: return "Norwegian krone"
        case .DKK: return "Danish krone"
        }
    }

    public var shortName: String {
        switch self {
        case .EUR: return "Euro"
        case .SEK: return "Krona"
        case .NOK: return "Krone"
        case .DKK: return "Krone"
        }
    }

    public var shortNamePlural: String {
        switch self {
        case .EUR: return "Euro"
        case .SEK: return "Kronor"
        case .NOK: return "Kroner"
        case .DKK: return "Kroner"
        }
    }

    public var symbol: String {
        switch self {
        case .EUR: return "€"
        case .SEK: return "kr"
        case .NOK: return "kr"
        case .DKK: return "kr"
        }
    }

    public var subdivision: CurrencySubdivision {
        switch self {
        case .EUR: return CurrencySubdivision(name: "Cent", symbol: "c", subdivisions: 100)
        case .SEK: return CurrencySubdivision(name: "Öre", symbol: "öre", subdivisions: 100)
        case .NOK: return CurrencySubdivision(name: "Øre", symbol: "øre", subdivisions: 100)
        case .DKK: return CurrencySubdivision(name: "Øre", symbol: "øre", subdivisions: 100)
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

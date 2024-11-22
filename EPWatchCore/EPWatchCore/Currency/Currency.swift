//
//  Currency.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-21.
//

import Foundation

public enum Currency: String, Codable, CaseIterable, Identifiable, Equatable, Sendable {

    case BGN
    case CHF
    case CZK
    case DKK
    case EUR
    case GBP
    case HUF
    case NOK
    case PLN
    case RON
    case SEK
    case TRY

    public var code: String {
        return rawValue
    }

    public var id: String {
        return code
    }

    public var name: String {
        switch self {
        case .BGN: return String(localized: "Bulgarian lev", bundle: .module, comment: "Currency name for BGN")
        case .CHF: return String(localized: "Swiss franc", bundle: .module, comment: "Currency name for CHF")
        case .CZK: return String(localized: "Czech koruna", bundle: .module, comment: "Currency name for CZK")
        case .DKK: return String(localized: "Danish krone", bundle: .module, comment: "Currency name for DKK")
        case .EUR: return String(localized: "Euro", bundle: .module, comment: "Currency name for EUR")
        case .GBP: return String(localized: "British pound", bundle: .module, comment: "Currency name for GBP")
        case .HUF: return String(localized: "Hungarian forint", bundle: .module, comment: "Currency name for HUF")
        case .NOK: return String(localized: "Norwegian krone", bundle: .module, comment: "Currency name for NOK")
        case .PLN: return String(localized: "Polish złoty", bundle: .module, comment: "Currency name for PLN")
        case .RON: return String(localized: "Romanian leu", bundle: .module, comment: "Currency name for RON")
        case .SEK: return String(localized: "Swedish krona", bundle: .module, comment: "Currency name for SEK")
        case .TRY: return String(localized: "Turkish lira", bundle: .module, comment: "Currency name for TRY")
        }
    }

    public var shortName: String {
        switch self {
        case .BGN: return String(localized: "Lev", bundle: .module, comment: "Currency name short for BGN")
        case .CHF: return String(localized: "Franc", bundle: .module, comment: "Currency name short for CHF")
        case .CZK: return String(localized: "Koruna", bundle: .module, comment: "Currency name short for CZK")
        case .DKK: return String(localized: "Krone", bundle: .module, comment: "Currency name short for DKK")
        case .EUR: return String(localized: "Euro", bundle: .module, comment: "Currency name short for EUR")
        case .GBP: return String(localized: "Pound", bundle: .module, comment: "Currency name short for GBP")
        case .HUF: return String(localized: "Forint", bundle: .module, comment: "Currency name short for HUF")
        case .NOK: return String(localized: "Krone", bundle: .module, comment: "Currency name short for NOK")
        case .PLN: return String(localized: "Złoty", bundle: .module, comment: "Currency name short for PLN")
        case .RON: return String(localized: "Leu", bundle: .module, comment: "Currency name short for RON")
        case .SEK: return String(localized: "Krona", bundle: .module, comment: "Currency name short for SEK")
        case .TRY: return String(localized: "Lira", bundle: .module, comment: "Currency name short for TRY")
        }
    }

    public var shortNamePlural: String {
        switch self {
        case .BGN: return String(localized: "Leva", bundle: .module, comment: "Currency name short plural for BGN")
        case .CHF: return String(localized: "Francs", bundle: .module, comment: "Currency name short plural for CHF")
        case .CZK: return String(localized: "Koruny", bundle: .module, comment: "Currency name short plural for CZK")
        case .DKK: return String(localized: "Kroner", bundle: .module, comment: "Currency name short plural for DKK")
        case .EUR: return String(localized: "Euro", bundle: .module, comment: "Currency name short plural for EUR")
        case .GBP: return String(localized: "Pound", bundle: .module, comment: "Currency name short plural for GBP")
        case .HUF: return String(localized: "Forints", bundle: .module, comment: "Currency name short plural for HUF")
        case .NOK: return String(localized: "Kroner", bundle: .module, comment: "Currency name short plural for NOK")
        case .PLN: return String(localized: "Złotych", bundle: .module, comment: "Currency name short plural for PLN")
        case .RON: return String(localized: "Lei", bundle: .module, comment: "Currency name short plural for RON")
        case .SEK: return String(localized: "Kronor", bundle: .module, comment: "Currency name short plural for SEK")
        case .TRY: return String(localized: "Lira", bundle: .module, comment: "Currency name short plural for TRY")
        }
    }

    public var symbol: String {
        switch self {
        case .BGN: return String(localized: "лв", bundle: .module, comment: "Currency symbol for BGN")
        case .CHF: return String(localized: "CHF", bundle: .module, comment: "Currency symbol for CHF")
        case .CZK: return String(localized: "Kč", bundle: .module, comment: "Currency symbol for CZK")
        case .DKK: return String(localized: "kr", bundle: .module, comment: "Currency symbol for DKK")
        case .EUR: return String(localized: "€", bundle: .module, comment: "Currency symbol for EUR")
        case .GBP: return String(localized: "£", bundle: .module, comment: "Currency symbol for GBP")
        case .HUF: return String(localized: "Ft", bundle: .module, comment: "Currency symbol for HUF")
        case .NOK: return String(localized: "kr", bundle: .module, comment: "Currency symbol for NOK")
        case .PLN: return String(localized: "zł", bundle: .module, comment: "Currency symbol for PLN")
        case .RON: return String(localized: "lei", bundle: .module, comment: "Currency symbol for RON")
        case .SEK: return String(localized: "kr", bundle: .module, comment: "Currency symbol for SEK")
        case .TRY: return String(localized: "₺", bundle: .module, comment: "Currency symbol for TRY")
        }
    }

    public var subdivision: CurrencySubdivision {
        switch self {
        case .BGN:
            return CurrencySubdivision(
                name: String(localized: "Stotinka", bundle: .module, comment: "Currency subdivision name for BGN"),
                symbol: String(localized: "st", bundle: .module, comment: "Currency subdivision symbol for BGN"),
                subdivisions: 100
            )
        case .CHF:
            return CurrencySubdivision(
                name: String(localized: "Rappen", bundle: .module, comment: "Currency subdivision name for CHF"),
                symbol: String(localized: "Rp", bundle: .module, comment: "Currency subdivision symbol for CHF"),
                subdivisions: 100
            )
        case .CZK:
            return CurrencySubdivision(
                name: String(localized: "Haléř", bundle: .module, comment: "Currency subdivision name for CZK"),
                symbol: String(localized: "h", bundle: .module, comment: "Currency subdivision symbol for CZK"),
                subdivisions: 100
            )
        case .DKK:
            return CurrencySubdivision(
                name: String(localized: "Øre", bundle: .module, comment: "Currency subdivision name for DKK"),
                symbol: String(localized: "øre", bundle: .module, comment: "Currency subdivision symbol for DKK"),
                subdivisions: 100
            )
        case .EUR:
            return CurrencySubdivision(
                name: String(localized: "Cent", bundle: .module, comment: "Currency subdivision name for EUR"),
                symbol: String(localized: "ct", bundle: .module, comment: "Currency subdivision symbol for EUR"),
                subdivisions: 100
            )
        case .GBP:
            return CurrencySubdivision(
                name: String(localized: "Penny", bundle: .module, comment: "Currency subdivision name for GBP"),
                symbol: String(localized: "p", bundle: .module, comment: "Currency subdivision symbol for GBP"),
                subdivisions: 100
            )
        case .HUF:
            // Hungarian Forint technically does not use subdivisions anymore.
            return CurrencySubdivision(
                name: String(localized: "Fillér", bundle: .module, comment: "Currency subdivision name for HUF"),
                symbol: String(localized: "f", bundle: .module, comment: "Currency subdivision symbol for HUF"),
                subdivisions: 100
            )
        case .NOK:
            return CurrencySubdivision(
                name: String(localized: "Øre", bundle: .module, comment: "Currency subdivision name for NOK"),
                symbol: String(localized: "øre", bundle: .module, comment: "Currency subdivision symbol for NOK"),
                subdivisions: 100
            )
        case .PLN:
            return CurrencySubdivision(
                name: String(localized: "Grosz", bundle: .module, comment: "Currency subdivision name for PLN"),
                symbol: String(localized: "gr", bundle: .module, comment: "Currency subdivision symbol for PLN"),
                subdivisions: 100
            )
        case .RON:
            return CurrencySubdivision(
                name: String(localized: "Ban", bundle: .module, comment: "Currency subdivision name for RON"),
                symbol: String(localized: "b", bundle: .module, comment: "Currency subdivision symbol for RON"),
                subdivisions: 100
            )
        case .SEK:
            return CurrencySubdivision(
                name: String(localized: "Öre", bundle: .module, comment: "Currency subdivision name for SEK"),
                symbol: String(localized: "öre", bundle: .module, comment: "Currency subdivision symbol for SEK"),
                subdivisions: 100
            )
        case .TRY:
            return CurrencySubdivision(
                name: String(localized: "Kuruş", bundle: .module, comment: "Currency subdivision name for TRY"),
                symbol: String(localized: "kr", bundle: .module, comment: "Currency subdivision symbol for TRY"),
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

    public var defaultPriceLimits: PriceLimits {
        switch self {
        case .BGN: return PriceLimits(.BGN, high: 0.6, low: 0.2)
        case .CHF: return PriceLimits(.CHF, high: 0.27, low: 0.09)
        case .CZK: return PriceLimits(.CZK, high: 7, low: 2.3)
        case .DKK: return PriceLimits(.DKK, high: 2, low: 0.7)
        case .EUR: return PriceLimits(.EUR, high: 0.3, low: 0.1)
        case .GBP: return PriceLimits(.GBP, high: 0.25, low: 0.08)
        case .HUF: return PriceLimits(.HUF, high: 90, low: 30)
        case .NOK: return PriceLimits(.NOK, high: 3, low: 1)
        case .PLN: return PriceLimits(.PLN, high: 1.2, low: 0.4)
        case .RON: return PriceLimits(.RON, high: 1.3, low: 0.45)
        case .SEK: return PriceLimits(.SEK, high: 3, low: 1)
        case .TRY: return PriceLimits(.TRY, high: 5.5, low: 1.8)
        }
    }

    public var priceLimitsRange: ClosedRange<Double> {
        return 0...(defaultPriceLimits.high*2)
    }

    public var priceLimitsStep: Double {
        let high = defaultPriceLimits.high
        if high <= 1.0 {
            return 0.005
        } else if high <= 10 {
            return 0.05
        } else {
            return 0.5
        }
    }

    static var defaultPriceLimitsDictionary: [Currency: PriceLimits] {
        Dictionary(grouping: allCases, by: { $0 })
            .mapValues({ $0[0].defaultPriceLimits })
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

    // swiftlint:disable:next cyclomatic_complexity function_body_length
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

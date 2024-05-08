//
//  Currency.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-21.
//

import Foundation

public enum Currency: String, Codable, CaseIterable, Identifiable, Equatable {

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
        func localized(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency name")
        }
        switch self {
        case .BGN: return localized("Bulgarian lev")
        case .CHF: return localized("Swiss franc")
        case .CZK: return localized("Czech koruna")
        case .DKK: return localized("Danish krone")
        case .EUR: return localized("Euro")
        case .GBP: return localized("British pound")
        case .HUF: return localized("Hungarian forint")
        case .NOK: return localized("Norwegian krone")
        case .PLN: return localized("Polish złoty")
        case .RON: return localized("Romanian leu")
        case .SEK: return localized("Swedish krona")
        case .TRY: return localized("Turkish lira")
        }
    }

    public var shortName: String {
        func localized(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency name short")
        }
        switch self {
        case .BGN: return localized("Lev")
        case .CHF: return localized("Franc")
        case .CZK: return localized("Koruna")
        case .DKK: return localized("Krone")
        case .EUR: return localized("Euro")
        case .GBP: return localized("Pound")
        case .HUF: return localized("Forint")
        case .NOK: return localized("Krone")
        case .PLN: return localized("Złoty")
        case .RON: return localized("Leu")
        case .SEK: return localized("Krona")
        case .TRY: return localized("Lira")
        }
    }

    public var shortNamePlural: String {
        func localized(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency name short plural")
        }
        switch self {
        case .BGN: return localized("Leva")
        case .CHF: return localized("Francs")
        case .CZK: return localized("Koruny")
        case .DKK: return localized("Kroner")
        case .EUR: return localized("Euro")
        case .GBP: return localized("Pound")
        case .HUF: return localized("Forints")
        case .NOK: return localized("Kroner")
        case .PLN: return localized("Złotych")
        case .RON: return localized("Lei")
        case .SEK: return localized("Kronor")
        case .TRY: return localized("Lira")
        }
    }

    public var symbol: String {
        func localized(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency symbol")
        }
        switch self {
        case .BGN: return localized("лв")
        case .CHF: return localized("CHF")
        case .CZK: return localized("Kč")
        case .DKK: return localized("kr")
        case .EUR: return localized("€")
        case .GBP: return localized("£")
        case .HUF: return localized("Ft")
        case .NOK: return localized("kr")
        case .PLN: return localized("zł")
        case .RON: return localized("lei")
        case .SEK: return localized("kr")
        case .TRY: return localized("₺")
        }
    }

    public var subdivision: CurrencySubdivision {
        func localizedName(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency subdivision name")
        }
        func localizedSymbol(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency subdivision symbol")
        }
        switch self {
        case .BGN:
            return CurrencySubdivision(
                name: localizedName("Stotinka"),
                symbol: localizedSymbol("st"),
                subdivisions: 100
            )
        case .CHF:
            return CurrencySubdivision(
                name: localizedName("Rappen"),
                symbol: localizedSymbol("Rp"),
                subdivisions: 100
            )
        case .CZK:
            return CurrencySubdivision(
                name: localizedName("Haléř"),
                symbol: localizedSymbol("h"),
                subdivisions: 100
            )
        case .DKK:
            return CurrencySubdivision(
                name: localizedName("Øre"),
                symbol: localizedSymbol("øre"),
                subdivisions: 100
            )
        case .EUR:
            return CurrencySubdivision(
                name: localizedName("Cent"),
                symbol: localizedSymbol("c"),
                subdivisions: 100
            )
        case .GBP:
            return CurrencySubdivision(
                name: localizedName("Penny"),
                symbol: localizedSymbol("p"),
                subdivisions: 100
            )
        case .HUF:
            // Hungarian Forint technically does not use subdivisions anymore.
            return CurrencySubdivision(
                name: localizedName("Fillér"),
                symbol: localizedSymbol("f"),
                subdivisions: 100
            )
        case .NOK:
            return CurrencySubdivision(
                name: localizedName("Øre"),
                symbol: localizedSymbol("øre"),
                subdivisions: 100
            )
        case .PLN:
            return CurrencySubdivision(
                name: localizedName("Grosz"),
                symbol: localizedSymbol("gr"),
                subdivisions: 100
            )
        case .RON:
            return CurrencySubdivision(
                name: localizedName("Ban"),
                symbol: localizedSymbol("b"),
                subdivisions: 100
            )
        case .SEK:
            return CurrencySubdivision(
                name: localizedName("Öre"),
                symbol: localizedSymbol("öre"),
                subdivisions: 100
            )
        case .TRY:
            return CurrencySubdivision(
                name: localizedName("Kuruş"),
                symbol: localizedSymbol("kr"),
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

    var minimumYAxisValues: [Double] {
        let low = defaultPriceLimits.low
        if low <= 0.3 {
            return [0.0, 0.05, 0.1, 0.15]
        } else if low <= 0.5 {
            return [0.0, 0.25, 0.5, 1.0]
        } else if low <= 1.0 {
            return  [0.0, 0.5, 1.0, 1.5]
        } else {
            return  [0.0, 5.0, 10.0, 15.0]
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

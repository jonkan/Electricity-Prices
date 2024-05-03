//
//  Currency.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-10-21.
//

import Foundation

// swiftlint:disable file_length
public enum Currency: String, Codable, CaseIterable, Identifiable, Equatable {

//    case ALL
//    case BAM
    case BGN
    case CHF
    case CZK
    case DKK
    case EUR
    case GBP
//    case GEL
//    case HRK
    case HUF
//    case MDL
//    case MKD
    case NOK
    case PLN
    case RON
//    case RSD
    case SEK
    case TRY
//    case UAH

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
//        case .ALL: return localized("Albanian lek")
//        case .BAM: return localized("Bosnia and Herzegovina convertible mark")
        case .BGN: return localized("Bulgarian lev")
        case .CHF: return localized("Swiss franc")
        case .CZK: return localized("Czech koruna")
        case .DKK: return localized("Danish krone")
        case .EUR: return localized("Euro")
        case .GBP: return localized("British pound")
//        case .GEL: return localized("Georgian lari")
//        case .HRK: return localized("Croatian kuna")
        case .HUF: return localized("Hungarian forint")
//        case .MDL: return localized("Moldovan leu")
//        case .MKD: return localized("Macedonian denar")
        case .NOK: return localized("Norwegian krone")
        case .PLN: return localized("Polish złoty")
        case .RON: return localized("Romanian leu")
//        case .RSD: return localized("Serbian dinar")
        case .SEK: return localized("Swedish krona")
        case .TRY: return localized("Turkish lira")
//        case .UAH: return localized("Ukrainian hryvnia")
        }
    }

    public var shortName: String {
        func localized(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency name short")
        }
        switch self {
//        case .ALL: return localized("Lek")
//        case .BAM: return localized("Mark")
        case .BGN: return localized("Lev")
        case .CHF: return localized("Franc")
        case .CZK: return localized("Koruna")
        case .DKK: return localized("Krone")
        case .EUR: return localized("Euro")
        case .GBP: return localized("Pound")
//        case .GEL: return localized("Lari")
//        case .HRK: return localized("Kuna")
        case .HUF: return localized("Forint")
//        case .MDL: return localized("Leu")
//        case .MKD: return localized("Denar")
        case .NOK: return localized("Krone")
        case .PLN: return localized("Złoty")
        case .RON: return localized("Leu")
//        case .RSD: return localized("Dinar")
        case .SEK: return localized("Krona")
        case .TRY: return localized("Lira")
//        case .UAH: return localized("Hryvnia")
        }
    }

    public var shortNamePlural: String {
        func localized(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency name short plural")
        }
        switch self {
//        case .ALL: return localized("Lekë")
//        case .BAM: return localized("Marks")
        case .BGN: return localized("Leva")
        case .CHF: return localized("Francs")
        case .CZK: return localized("Koruny")
        case .DKK: return localized("Kroner")
        case .EUR: return localized("Euro")
        case .GBP: return localized("Pound")
//        case .GEL: return localized("Lari")
//        case .HRK: return localized("Kuna")
        case .HUF: return localized("Forints")
//        case .MDL: return localized("Lei")
//        case .MKD: return localized("Denari")
        case .NOK: return localized("Kroner")
        case .PLN: return localized("Złotych")
        case .RON: return localized("Lei")
//        case .RSD: return localized("Dinars")
        case .SEK: return localized("Kronor")
        case .TRY: return localized("Lira")
//        case .UAH: return localized("Hryvnias")
        }
    }

    public var symbol: String {
        func localized(_ key: String.LocalizationValue) -> String {
            String(localized: key, bundle: .module, comment: "Currency symbol")
        }
        switch self {
//        case .ALL: return localized("L")
//        case .BAM: return localized("KM")
        case .BGN: return localized("лв")
        case .CHF: return localized("CHF")
        case .CZK: return localized("Kč")
        case .DKK: return localized("kr")
        case .EUR: return localized("€")
        case .GBP: return localized("£")
//        case .GEL: return localized("₾")
//        case .HRK: return localized("kn")
        case .HUF: return localized("Ft")
//        case .MDL: return localized("MDL")
//        case .MKD: return localized("ден")
        case .NOK: return localized("kr")
        case .PLN: return localized("zł")
        case .RON: return localized("lei")
//        case .RSD: return localized("дин")
        case .SEK: return localized("kr")
        case .TRY: return localized("₺")
//        case .UAH: return localized("₴")
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
//        case .ALL:
//            return CurrencySubdivision(
//                name: localizedName("Qindarka"),
//                symbol: localizedSymbol("q"),
//                subdivisions: 100
//            )
//        case .BAM:
//            return CurrencySubdivision(
//                name: localizedName("Fening"),
//                symbol: localizedSymbol("pf"),
//                subdivisions: 100
//            )
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
//        case .GEL:
//            // Georgian Lari does not have a widely used subdivision.
//            return CurrencySubdivision(
//                name: localizedName("Tetri"),
//                symbol: localizedSymbol("tetri"),
//                subdivisions: 100
//            )
//        case .HRK:
//            return CurrencySubdivision(
//                name: localizedName("Lipa"),
//                symbol: localizedSymbol("lp"),
//                subdivisions: 100
//            )
        case .HUF:
            // Hungarian Forint technically does not use subdivisions anymore.
            return CurrencySubdivision(
                name: localizedName("Fillér"),
                symbol: localizedSymbol("f"),
                subdivisions: 100
            )
//        case .MDL:
//            return CurrencySubdivision(
//                name: localizedName("Ban"),
//                symbol: localizedSymbol("b"),
//                subdivisions: 100
//            )
//        case .MKD:
//            return CurrencySubdivision(
//                name: localizedName("Deni"),
//                symbol: localizedSymbol("deni"),
//                subdivisions: 100
//            )
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
//        case .RSD:
//            return CurrencySubdivision(
//                name: localizedName("Para"),
//                symbol: localizedSymbol("para"),
//                subdivisions: 100
//            )
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
//        case .UAH:
//            return CurrencySubdivision(
//                name: localizedName("Kopiyka"),
//                symbol: localizedSymbol("kop"),
//                subdivisions: 100
//            )
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
//        case .ALL: return PriceLimits(.ALL, high: 35, low: 12)
//        case .BAM: return PriceLimits(.BAM, high: 0.6, low: 0.2)
        case .BGN: return PriceLimits(.BGN, high: 0.6, low: 0.2)
        case .CHF: return PriceLimits(.CHF, high: 0.27, low: 0.09)
        case .CZK: return PriceLimits(.CZK, high: 7, low: 2.3)
        case .DKK: return PriceLimits(.DKK, high: 2, low: 0.7)
        case .EUR: return PriceLimits(.EUR, high: 0.3, low: 0.1)
        case .GBP: return PriceLimits(.GBP, high: 0.25, low: 0.08)
//        case .GEL: return PriceLimits(.GEL, high: 0.9, low: 0.3)
//        case .HRK: return PriceLimits(.HRK, high: 2.3, low: 0.8)
        case .HUF: return PriceLimits(.HUF, high: 90, low: 30)
//        case .MDL: return PriceLimits(.MDL, high: 5.5, low: 1.8)
//        case .MKD: return PriceLimits(.MKD, high: 18, low: 6)
        case .NOK: return PriceLimits(.NOK, high: 3, low: 1)
        case .PLN: return PriceLimits(.PLN, high: 1.2, low: 0.4)
        case .RON: return PriceLimits(.RON, high: 1.3, low: 0.45)
//        case .RSD: return PriceLimits(.RSD, high: 35, low: 12)
        case .SEK: return PriceLimits(.SEK, high: 3, low: 1)
        case .TRY: return PriceLimits(.TRY, high: 5.5, low: 1.8)
//        case .UAH: return PriceLimits(.UAH, high: 9, low: 3)
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

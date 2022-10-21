//
//  PriceFormatter.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-13.
//

import Foundation

struct PriceFormatter {

    static private let formatterNormal: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "SEK"
        nf.maximumSignificantDigits = 3
        return nf
    }()

    static private let formatterNormalSmall: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .currency
        nf.currencyCode = "SEK"
        nf.maximumFractionDigits = 2
        return nf
    }()

    static private let formatterShort: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumSignificantDigits = 2
        return nf
    }()

    static private let formatterShortSmall: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = 1
        return nf
    }()

    static func formatted(_ price: Double, style: FormattingStyle) -> String {
        switch style {
        case .normal:
            if price >= 1 {
                return formatterNormal.string(from: price as NSNumber) ?? ""
            } else {
                return formatterNormalSmall.string(from: price as NSNumber) ?? ""
            }
        case .short:
            if price >= 1 {
                return formatterShort.string(from: price as NSNumber) ?? ""
            } else {
                return formatterShortSmall.string(from: price as NSNumber) ?? ""
            }
        }
    }
}

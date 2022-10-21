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
        nf.usesSignificantDigits = true
        nf.maximumSignificantDigits = 3
        nf.maximumFractionDigits = 2
        return nf
    }()

    static private let formatterShort: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.usesSignificantDigits = true
        nf.maximumSignificantDigits = 2
        nf.maximumFractionDigits = 1
        return nf
    }()

    static func formatted(_ price: Double, style: FormattingStyle) -> String {
        switch style {
        case .normal:
            return formatterNormal.string(from: price as NSNumber) ?? ""
        case .short:
            return formatterShort.string(from: price as NSNumber) ?? ""
        }
    }
}

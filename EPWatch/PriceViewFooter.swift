//
//  PriceViewFooter.swift
//  EPWatch
//
//  Created by Jonas Bromö on 2022-10-24.
//

import SwiftUI
import EPWatchCore

struct PriceViewFooter: View {
    
    let priceArea: PriceArea?
    let region: Region?
    let exchangeRate: ExchangeRate?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let priceArea = priceArea, let region = region {
                Text("Price area: \(priceArea.title + ", " + region.name.localized)")
            }
            if let exchangeRate = exchangeRate,
               exchangeRate.to != .EUR,
               let formattedRate = exchangeRate.formattedRate() {
                Text("Exchange rate: \(formattedRate + " " + exchangeRate.to.name.localized + "/" + exchangeRate.from.name.localized)")
            }
        }
        .font(.caption)
    }
    
}

struct PriceViewFooter_Previews: PreviewProvider {
    static var previews: some View {
        PriceViewFooter(
            priceArea: Region.sweden.priceAreas.first,
            region: .sweden,
            exchangeRate: .mocked
        )
    }
}

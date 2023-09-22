//
//  PricePointInlineWidgetView.swift
//  EPWatchCore
//
//  Created by Jonas Bromö on 2022-09-18.
//

import Foundation

import SwiftUI

public struct PricePointInlineWidgetView: View {

    let entry: PricePointTimelineEntry

    public init(entry: PricePointTimelineEntry) {
        self.entry = entry
    }

    public var body: some View {
        Text(entry.formattedPrice(style: .normal))
            .bold()
            .foregroundColor(entry.limits.color(of: entry.pricePoint.price))
    }

}

struct PricePointInlineWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        PricePointInlineWidgetView(entry: .mock)
    }
}

